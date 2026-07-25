import AppKit
import SwiftUI

/// Esc closes the guide. It reaches here only when nothing in the window claimed
/// it first — the shortcut recorder does, to cancel recording.
final class EscapeClosingWindow: NSWindow {
    override func cancelOperation(_ sender: Any?) { performClose(sender) }
}

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
        let window = EscapeClosingWindow(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 470),
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
        window.setContentSizeClamped(NSSize(width: 640, height: 470))
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
