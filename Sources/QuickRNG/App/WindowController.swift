import AppKit
import SwiftUI

/// The app lives in the menu bar (accessory), but flips to a regular app while
/// the window is open so it gets a Dock icon and a proper menu bar.
@MainActor
final class WindowController: NSObject, NSWindowDelegate {
    static let shared = WindowController()

    private var window: NSWindow?

    func show() {
        if window == nil { window = makeWindow() }
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
        window?.center()
        AppState.shared.focusInput()
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 440, height: 560),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Quick RNG"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.backgroundColor = .windowBackgroundColor
        window.contentView = NSHostingView(rootView: WindowView())
        window.delegate = self
        window.isReleasedWhenClosed = false
        window.setFrameAutosaveName("QuickRNGWindow")
        return window
    }

    func windowWillClose(_ notification: Notification) {
        // Back to a pure menu bar app once the window is gone.
        DispatchQueue.main.async { NSApp.setActivationPolicy(.accessory) }
    }
}
