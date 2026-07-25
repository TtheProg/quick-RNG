import AppKit
import Carbon.HIToolbox

/// A global keyboard shortcut, as recorded from a real key press.
///
/// The label is stored alongside the key code rather than derived from it:
/// translating a virtual key code back into a printable character depends on
/// the active keyboard layout, and the character the user actually pressed is
/// the one they'll look for.
struct Shortcut: Equatable {
    var keyCode: UInt16
    var modifierFlags: NSEvent.ModifierFlags
    var label: String

    /// ⇧⌘R — easy to grab one-handed and easy to remember. It is not free:
    /// measured against the running apps' menus it collides with Finder's
    /// AirDrop, Safari's Reader, Mail's "Allen antworten" and Edge's reload, and
    /// a global hot key wins over all of them. Deliberate trade-off; anyone it
    /// bothers changes it in the settings.
    static let `default` = Shortcut(keyCode: UInt16(kVK_ANSI_R),
                                    modifierFlags: [.shift, .command],
                                    label: "R")

    /// Carbon wants its own modifier bitmask.
    var carbonModifiers: UInt32 {
        var m: UInt32 = 0
        if modifierFlags.contains(.command) { m |= UInt32(cmdKey) }
        if modifierFlags.contains(.option)  { m |= UInt32(optionKey) }
        if modifierFlags.contains(.control) { m |= UInt32(controlKey) }
        if modifierFlags.contains(.shift)   { m |= UInt32(shiftKey) }
        return m
    }

    var display: String {
        var s = ""
        if modifierFlags.contains(.control) { s += "⌃" }
        if modifierFlags.contains(.option)  { s += "⌥" }
        if modifierFlags.contains(.shift)   { s += "⇧" }
        if modifierFlags.contains(.command) { s += "⌘" }
        return s + label
    }

    /// A shortcut with no modifier would swallow ordinary typing system-wide.
    var isUsable: Bool {
        !modifierFlags.intersection([.command, .option, .control]).isEmpty
    }

    /// Reads a recorded key event. Returns nil for modifier-only presses.
    init?(event: NSEvent) {
        let flags = event.modifierFlags.intersection([.command, .option, .control, .shift])
        guard let chars = event.charactersIgnoringModifiers, !chars.isEmpty else { return nil }
        self.keyCode = UInt16(event.keyCode)
        self.modifierFlags = flags
        self.label = Shortcut.label(for: UInt16(event.keyCode), fallback: chars)
    }

    init(keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags, label: String) {
        self.keyCode = keyCode
        self.modifierFlags = modifierFlags
        self.label = label
    }

    private static func label(for keyCode: UInt16, fallback: String) -> String {
        let named: [Int: String] = [
            kVK_Space: "Leer", kVK_Return: "↩", kVK_Tab: "⇥",
            kVK_LeftArrow: "←", kVK_RightArrow: "→", kVK_UpArrow: "↑", kVK_DownArrow: "↓",
            kVK_F1: "F1", kVK_F2: "F2", kVK_F3: "F3", kVK_F4: "F4", kVK_F5: "F5",
            kVK_F6: "F6", kVK_F7: "F7", kVK_F8: "F8", kVK_F9: "F9", kVK_F10: "F10",
            kVK_F11: "F11", kVK_F12: "F12"
        ]
        if let n = named[Int(keyCode)] { return n }
        return fallback.uppercased()
    }

    // MARK: - Persistence

    private static let key = "quickrng.shortcut"

    static func load() -> Shortcut? {
        guard let d = UserDefaults.standard.dictionary(forKey: key) else { return .default }
        if d["disabled"] as? Bool == true { return nil }
        guard let code = d["keyCode"] as? Int,
              let flags = d["modifiers"] as? UInt,
              let label = d["label"] as? String else { return .default }
        return Shortcut(keyCode: UInt16(code),
                        modifierFlags: NSEvent.ModifierFlags(rawValue: flags),
                        label: label)
    }

    static func save(_ shortcut: Shortcut?) {
        guard let shortcut else {
            UserDefaults.standard.set(["disabled": true], forKey: key)
            return
        }
        UserDefaults.standard.set([
            "keyCode": Int(shortcut.keyCode),
            "modifiers": shortcut.modifierFlags.rawValue,
            "label": shortcut.label
        ], forKey: key)
    }
}
