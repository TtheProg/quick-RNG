import ServiceManagement

/// "Bei Anmeldung starten". A menu bar tool you have to launch by hand is a
/// menu bar tool you stop using.
enum LoginItem {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func toggle() {
        do {
            if isEnabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            NSLog("Quick RNG: Login-Item konnte nicht geändert werden — \(error.localizedDescription)")
        }
    }
}
