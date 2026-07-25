import AppKit
import SwiftUI

/// The Anleitung gets its own window so it can be opened from the menu bar panel
/// without the panel having to survive the click.
@MainActor
final class GuideWindowController: NSObject, NSWindowDelegate {
    static let shared = GuideWindowController()

    private var window: NSWindow?

    func show() {
        if window == nil { window = makeWindow() }
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 680),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Quick RNG — Anleitung"
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.backgroundColor = .windowBackgroundColor
        window.contentView = NSHostingView(rootView: GuideView())
        window.delegate = self
        window.isReleasedWhenClosed = false
        window.setFrameAutosaveName("QuickRNGGuide")
        window.center()
        return window
    }

    func windowWillClose(_ notification: Notification) {
        // Only drop back to menu-bar-only if no other window is left open.
        let closing = notification.object as? NSWindow
        DispatchQueue.main.async {
            let stillOpen = NSApp.windows.contains {
                $0 !== closing && $0.isVisible && $0.canBecomeMain
            }
            if !stillOpen { NSApp.setActivationPolicy(.accessory) }
        }
    }
}
