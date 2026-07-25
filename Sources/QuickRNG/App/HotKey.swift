import AppKit
import Carbon.HIToolbox

/// One registered system-wide hot key. Uses the Carbon hot key API, which —
/// unlike a CGEvent tap — needs no accessibility permission.
final class HotKey {
    private var ref: EventHotKeyRef?
    private let id: UInt32

    private static var callbacks: [UInt32: () -> Void] = [:]
    private static var nextID: UInt32 = 1
    private static var handler: EventHandlerRef?

    init?(shortcut: Shortcut, action: @escaping () -> Void) {
        guard shortcut.isUsable else { return nil }
        HotKey.installHandlerIfNeeded()

        id = HotKey.nextID
        HotKey.nextID += 1
        HotKey.callbacks[id] = action

        let hotKeyID = EventHotKeyID(signature: OSType(0x51524E47), id: id) // 'QRNG'
        let status = RegisterEventHotKey(UInt32(shortcut.keyCode), shortcut.carbonModifiers,
                                         hotKeyID, GetApplicationEventTarget(), 0, &ref)
        guard status == noErr else {
            HotKey.callbacks[id] = nil
            return nil
        }
    }

    deinit {
        if let ref { UnregisterEventHotKey(ref) }
        HotKey.callbacks[id] = nil
    }

    /// One process-wide handler dispatches to whichever hot key fired.
    private static func installHandlerIfNeeded() {
        guard handler == nil else { return }
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, event, _ -> OSStatus in
            var hkID = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject),
                              EventParamType(typeEventHotKeyID), nil,
                              MemoryLayout<EventHotKeyID>.size, nil, &hkID)
            DispatchQueue.main.async { HotKey.callbacks[hkID.id]?() }
            return noErr
        }, 1, &eventType, nil, &handler)
    }
}

/// Owns the current shortcut and keeps the registration in sync with it.
@MainActor
final class HotKeyManager: ObservableObject {
    static let shared = HotKeyManager()

    /// nil means "no shortcut" — either the user cleared it, or registration
    /// failed because another app already owns the combination.
    @Published private(set) var shortcut: Shortcut?
    @Published private(set) var registrationFailed = false

    private var hotKey: HotKey?
    private var action: (() -> Void)?

    private init() {
        shortcut = Shortcut.load()
    }

    func start(action: @escaping () -> Void) {
        self.action = action
        register()
    }

    func update(to newValue: Shortcut?) {
        shortcut = newValue
        Shortcut.save(newValue)
        register()
    }

    private func register() {
        hotKey = nil                       // unregister the old one first
        registrationFailed = false
        guard let shortcut, let action else { return }
        hotKey = HotKey(shortcut: shortcut, action: action)
        registrationFailed = hotKey == nil
    }
}
