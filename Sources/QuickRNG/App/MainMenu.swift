import AppKit

/// The app had no main menu at all, which on macOS also means no ⌘C / ⌘V / ⌘A
/// in the input field — those key equivalents are delivered by menu items, not
/// by the text system. So the menu earns its place even though the app spends
/// most of its life as a menu bar accessory with the menu hidden.
enum MainMenu {

    static func build(target: AnyObject) -> NSMenu {
        let main = NSMenu()
        main.addItem(appMenu(target: target))
        main.addItem(editMenu())
        main.addItem(windowMenu())
        return main
    }

    private static func submenu(_ title: String, _ items: [NSMenuItem]) -> NSMenuItem {
        let item = NSMenuItem()
        let menu = NSMenu(title: title)
        items.forEach { menu.addItem($0) }
        item.submenu = menu
        return item
    }

    private static func item(_ title: String, _ action: Selector?, _ key: String,
                             modifiers: NSEvent.ModifierFlags = .command,
                             target: AnyObject? = nil) -> NSMenuItem {
        let i = NSMenuItem(title: title, action: action, keyEquivalent: key)
        i.keyEquivalentModifierMask = modifiers
        i.target = target
        return i
    }

    private static func appMenu(target: AnyObject) -> NSMenuItem {
        submenu("Quick RNG", [
            item("Über Quick RNG", #selector(NSApplication.orderFrontStandardAboutPanel(_:)), ""),
            .separator(),
            item("Einstellungen …", Selector(("openSettings")), ",", target: target),
            item("Anleitung", Selector(("openGuide")), "?", target: target),
            .separator(),
            item("Quick RNG ausblenden", #selector(NSApplication.hide(_:)), "h"),
            item("Andere ausblenden", #selector(NSApplication.hideOtherApplications(_:)), "h",
                 modifiers: [.command, .option]),
            .separator(),
            item("Quick RNG beenden", #selector(NSApplication.terminate(_:)), "q"),
        ])
    }

    private static func editMenu() -> NSMenuItem {
        submenu("Bearbeiten", [
            item("Widerrufen", Selector(("undo:")), "z"),
            item("Wiederholen", Selector(("redo:")), "z", modifiers: [.command, .shift]),
            .separator(),
            item("Ausschneiden", #selector(NSText.cut(_:)), "x"),
            item("Kopieren", #selector(NSText.copy(_:)), "c"),
            item("Einsetzen", #selector(NSText.paste(_:)), "v"),
            item("Alles auswählen", #selector(NSText.selectAll(_:)), "a"),
        ])
    }

    private static func windowMenu() -> NSMenuItem {
        let item = submenu("Fenster", [
            MainMenu.item("Im Dock ablegen", #selector(NSWindow.performMiniaturize(_:)), "m"),
            MainMenu.item("Schließen", #selector(NSWindow.performClose(_:)), "w"),
        ])
        NSApp.windowsMenu = item.submenu
        return item
    }
}
