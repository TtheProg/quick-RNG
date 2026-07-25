import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var outsideClickMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.mainMenu = MainMenu.build(target: self)

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            button.image = Theme.statusIcon()
            button.image?.accessibilityDescription = "Quick RNG"
            button.target = self
            button.action = #selector(statusItemClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        statusItem = item

        // ⇧⌘R by default; changeable in the settings. Pressing it again closes
        // the panel, so the same keystroke gets you in and out.
        MainActor.assumeIsolated {
            HotKeyManager.shared.start { [weak self] in
                MainActor.assumeIsolated {
                    PanelController.shared.toggleFromShortcut(relativeTo: self?.statusItem?.button)
                }
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
        menu.addItem(withTitle: "Einstellungen …", action: #selector(openSettings), keyEquivalent: ",")
            .target = self
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
    @objc func openGuide() {
        GuideWindowController.shared.show()
    }

    @MainActor
    @objc func openSettings() {
        SettingsWindowController.shared.show()
    }

    @MainActor
    @objc private func openWindow() {
        WindowController.shared.show()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let outsideClickMonitor { NSEvent.removeMonitor(outsideClickMonitor) }
    }
}
