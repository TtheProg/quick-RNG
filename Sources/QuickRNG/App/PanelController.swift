import AppKit
import SwiftUI

/// A borderless, non-activating panel. `.nonactivatingPanel` + `canBecomeKey` is
/// what lets the text field take the keyboard without yanking the frontmost app
/// out from under you.
final class RNGPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

@MainActor
final class PanelController: NSObject, NSWindowDelegate {
    static let shared = PanelController()

    private var panel: RNGPanel?
    private var hostingView: NSHostingView<PanelView>?
    private var lastHide: Date = .distantPast
    private var lastShow: Date = .distantPast
    private let width: CGFloat = 380

    var isVisible: Bool { panel?.isVisible ?? false }

    func toggle(relativeTo button: NSStatusBarButton?) {
        // Clicking the status item while the panel is open makes the panel resign
        // key first, which already hides it — so don't immediately re-open.
        if isVisible || Date().timeIntervalSince(lastHide) < 0.2 {
            hide()
            return
        }
        show(relativeTo: button)
    }

    func show(relativeTo button: NSStatusBarButton?) {
        let panel = panel ?? makePanel()
        position(panel, under: button)
        lastShow = Date()
        panel.alphaValue = 0
        panel.makeKeyAndOrderFront(nil)
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.12
            panel.animator().alphaValue = 1
        }
        AppState.shared.focusInput()
    }

    func hide() {
        guard let panel, panel.isVisible else { return }
        lastHide = Date()
        panel.orderOut(nil)
    }

    private func makePanel() -> RNGPanel {
        let panel = RNGPanel(
            contentRect: NSRect(x: 0, y: 0, width: width, height: 220),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .popUpMenu
        panel.hidesOnDeactivate = false
        panel.isMovable = false
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.animationBehavior = .none
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.delegate = self

        let root = PanelView(onHeightChange: { [weak self] h in self?.resize(to: h) })
        let host = NSHostingView(rootView: root)
        host.frame = panel.contentLayoutRect
        panel.contentView = host
        hostingView = host
        self.panel = panel
        return panel
    }

    /// The panel grows downward from the menu bar, so keep the top edge pinned.
    private func resize(to height: CGFloat) {
        guard let panel, height > 1 else { return }
        let h = height.rounded(.up)
        guard abs(panel.frame.height - h) > 0.5 else { return }
        var frame = panel.frame
        frame.origin.y += frame.height - h
        frame.size.height = h
        panel.setFrame(frame, display: true)
    }

    private func position(_ panel: NSPanel, under button: NSStatusBarButton?) {
        guard let button, let buttonWindow = button.window else { return }
        let inScreen = buttonWindow.convertToScreen(button.convert(button.bounds, to: nil))
        var x = inScreen.midX - panel.frame.width / 2
        var y = inScreen.minY - panel.frame.height - 6

        if let screen = NSScreen.screens.first(where: { $0.frame.intersects(inScreen) }) ?? NSScreen.main {
            let visible = screen.visibleFrame
            x = min(max(x, visible.minX + 8), visible.maxX - panel.frame.width - 8)
            y = max(y, visible.minY + 8)
        }
        panel.setFrameOrigin(NSPoint(x: x.rounded(), y: y.rounded()))
    }

    func windowDidResignKey(_ notification: Notification) {
        // A panel opened while another app is frontmost can bounce out of key
        // state immediately; don't let that close it before it's even seen.
        guard Date().timeIntervalSince(lastShow) > 0.4 else { return }
        hide()
    }
}
