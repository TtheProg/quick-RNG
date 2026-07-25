import SwiftUI
import AppKit

/// Click, press the combination you want, done. `esc` cancels, `⌫` clears it.
struct ShortcutRecorder: View {
    @ObservedObject private var manager = HotKeyManager.shared
    @State private var recording = false
    @State private var monitor: Any?

    private var accent: Color { Theme.accent(.number) }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Kurzbefehl")
                    .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.ink)
                Text(status)
                    .font(.system(size: 11.5, design: .rounded))
                    .foregroundStyle(manager.registrationFailed ? Theme.accent(.coin) : Theme.inkMuted)
            }
            Spacer(minLength: 12)

            Button(action: toggle) {
                Text(recording ? "drücke Tasten …" : (manager.shortcut?.display ?? "keiner"))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(recording ? accent : Theme.ink)
                    .frame(minWidth: 116)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Theme.fillStrong)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(recording ? accent : Theme.hairline,
                                            lineWidth: recording ? 1.5 : 0.75)
                            )
                    )
            }
            .buttonStyle(.plain)
            .help("Klicken und die gewünschte Tastenkombination drücken")
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.fill.opacity(0.8)))
        .onDisappear(perform: stop)
    }

    private var status: String {
        if manager.registrationFailed {
            return "Belegt — eine andere App hat diese Kombination."
        }
        if recording { return "esc bricht ab · ⌫ entfernt den Kurzbefehl" }
        return manager.shortcut == nil
            ? "Kein Kurzbefehl — das Menüleisten-Icon geht weiterhin."
            : "Öffnet das Panel von überall."
    }

    private func toggle() {
        recording ? stop() : start()
    }

    private func start() {
        recording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            MainActor.assumeIsolated {
                switch Int(event.keyCode) {
                case 53:            // esc — keep what we had
                    stop()
                case 51, 117:       // delete / forward delete — no shortcut
                    manager.update(to: nil)
                    stop()
                default:
                    if let s = Shortcut(event: event), s.isUsable {
                        manager.update(to: s)
                        stop()
                    }
                }
            }
            return nil              // swallow it either way
        }
    }

    private func stop() {
        recording = false
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
    }
}
