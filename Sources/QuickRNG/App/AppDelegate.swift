import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var outsideClickMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            button.image = Theme.statusIcon()
            button.image?.accessibilityDescription = "Quick RNG"
            button.target = self
            button.action = #selector(statusItemClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        statusItem = item

        // ⌥⌘R by default; changeable in the Anleitung.
        MainActor.assumeIsolated {
            HotKeyManager.shared.start { [weak self] in
                MainActor.assumeIsolated { self?.openPanel() }
            }
        }

        // Clicks in other apps dismiss the panel (resignKey doesn't always fire
        // for a non-activating panel).
        outsideClickMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown]
        ) { _ in
            MainActor.assumeIsolated { PanelController.shared.hide() }
        }

        // `--appearance light|dark` forces one mode — for checking both designs
        // without touching the system setting.
        if let i = CommandLine.arguments.firstIndex(of: "--appearance"),
           CommandLine.arguments.count > i + 1 {
            NSApp.appearance = NSAppearance(named: CommandLine.arguments[i + 1] == "light" ? .aqua : .darkAqua)
        }

        // `--window` / `--guide` / `--open` launch straight into one surface.
        let args = CommandLine.arguments
        if args.contains("--window") {
            WindowController.shared.show()
        } else if args.contains("--guide") {
            GuideWindowController.shared.show()
        } else if args.contains("--open") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                MainActor.assumeIsolated { self?.openPanel() }
            }
        }
    }

    @MainActor
    @objc private func statusItemClicked() {
        guard let event = NSApp.currentEvent else { return openPanel() }
        if event.type == .rightMouseUp || event.modifierFlags.contains(.control) {
            showContextMenu()
        } else {
            PanelController.shared.toggle(relativeTo: statusItem?.button)
        }
    }

    @MainActor
    private func openPanel() {
        PanelController.shared.show(relativeTo: statusItem?.button)
    }

    @MainActor
    private func showContextMenu() {
        let menu = NSMenu()
        menu.addItem(withTitle: "Als Fenster öffnen", action: #selector(openWindow), keyEquivalent: "o")
            .target = self
        menu.addItem(withTitle: "Anleitung", action: #selector(openGuide), keyEquivalent: "?")
            .target = self
        let login = menu.addItem(withTitle: "Bei Anmeldung starten",
                                 action: #selector(toggleLoginItem), keyEquivalent: "")
        login.target = self
        login.state = LoginItem.isEnabled ? .on : .off
        menu.addItem(.separator())
        let shortcut = HotKeyManager.shared.shortcut
        let hint = shortcut.map { "Überall öffnen mit \($0.display)" } ?? "Kein Kurzbefehl gesetzt"
        menu.addItem(withTitle: hint, action: nil, keyEquivalent: "").isEnabled = false
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quick RNG beenden", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    @MainActor
    @objc private func openGuide() {
        GuideWindowController.shared.show()
    }

    @MainActor
    @objc private func toggleLoginItem() {
        LoginItem.toggle()
    }

    @MainActor
    @objc private func openWindow() {
        WindowController.shared.show()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let outsideClickMonitor { NSEvent.removeMonitor(outsideClickMonitor) }
    }
}
