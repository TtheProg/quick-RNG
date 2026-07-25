import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSObject, NSWindowDelegate {
    static let shared = SettingsWindowController()

    private var window: NSWindow?

    func show() {
        if window == nil { window = makeWindow() }
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    private func makeWindow() -> NSWindow {
        let window = EscapeClosingWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 380),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Quick RNG — Einstellungen"
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.backgroundColor = .windowBackgroundColor
        window.contentView = NSHostingView(rootView: SettingsView())
        window.delegate = self
        window.isReleasedWhenClosed = false
        window.setFrameAutosaveName("QuickRNGSettings")
        window.center()
        return window
    }

    func windowWillClose(_ notification: Notification) {
        let closing = notification.object as? NSWindow
        DispatchQueue.main.async {
            let stillOpen = NSApp.windows.contains {
                $0 !== closing && $0.isVisible && $0.canBecomeMain
            }
            if !stillOpen { NSApp.setActivationPolicy(.accessory) }
        }
    }
}
