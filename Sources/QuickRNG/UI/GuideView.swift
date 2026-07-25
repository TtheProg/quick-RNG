import SwiftUI

/// The Anleitung. Reachable from the `?` in the panel and in the window — the
/// syntax is guessable but not discoverable, so it needs a home.
struct GuideView: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                intro
                section("Eingaben", entries: inputs)
                section("Tasten", entries: keys)
                VStack(alignment: .leading, spacing: 12) {
                    Text("EINSTELLUNGEN")
                        .font(.system(size: 10.5, weight: .heavy, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(Theme.inkFaint)
                    ShortcutRecorder()
                }
                extras
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 26)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            ZStack {
                VisualEffect(material: .underWindowBackground)
                Theme.surface
                LinearGradient(colors: [Theme.accent(.number).opacity(scheme == .dark ? 0.12 : 0.10), .clear],
                               startPoint: .top, endPoint: .center)
            }
            .ignoresSafeArea()
        )
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ANLEITUNG")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(2)
                .foregroundStyle(Theme.inkFaint)
            Text("Ein Feld für alles")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.ink)
            Text("Icon anklicken oder ⌥⌘R drücken — der Cursor steht schon im Feld. "
               + "Tippen, Return, fertig. Danach ist der Text komplett markiert: "
               + "nochmal Return würfelt neu, Tippen überschreibt.\n\n"
               + "Was gewürfelt wird, leitet Quick RNG aus deiner Eingabe ab. "
               + "Der Chip oben rechts zeigt schon beim Tippen, wie sie verstanden wurde.")
                .font(.system(size: 13.5, design: .rounded))
                .foregroundStyle(Theme.inkMuted)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private let inputs: [(String, String)] = [
        ("(leer)", "Zahl von 1 bis 100"),
        ("100", "Zahl von 1 bis 100"),
        ("3 - 9", "Ganzzahl im Bereich — auch 3..9 oder 3 bis 9"),
        ("1.5 - 2.5", "Kommazahl im Bereich"),
        ("rot, grün, blau", "eine der Optionen"),
        ("ja / nein", "eine der Optionen — , ; | / trennen"),
        ("3x a, b, c, d", "drei verschiedene Optionen"),
        ("shuffle a, b, c", "die komplette Reihenfolge"),
        ("2d6", "zwei sechsseitige Würfel, Einzelwürfe darunter"),
        ("d20  ·  3w8+2", "geht auch — d oder w, mit Modifikator"),
        ("1.1.26 - 31.12.26", "Datum im Zeitraum"),
        ("2026-01-01 - 2026-12-31", "auch ISO, auch TT/MM/JJJJ"),
        ("münze", "Kopf oder Zahl — coin, flip, toss"),
    ]

    private let keys: [(String, String)] = [
        ("Return", "würfeln — und gleich nochmal für einen neuen Wurf"),
        ("↑ / ↓", "durch frühere Eingaben blättern"),
        ("esc", "Panel schließen — und dieses Fenster hier"),
        ("⌥⌘R", "Panel von überall öffnen (unten einstellbar)"),
    ]

    private func section(_ title: String, entries: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 10.5, weight: .heavy, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(Theme.inkFaint)

            VStack(alignment: .leading, spacing: 9) {
                ForEach(entries, id: \.0) { entry in
                    HStack(alignment: .firstTextBaseline, spacing: 14) {
                        Text(entry.0)
                            .font(.system(size: 12.5, weight: .medium, design: .monospaced))
                            .foregroundStyle(Theme.ink)
                            .frame(width: 190, alignment: .leading)
                        Text(entry.1)
                            .font(.system(size: 12.5, design: .rounded))
                            .foregroundStyle(Theme.inkMuted)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 10).fill(Theme.fill.opacity(0.8)))
        }
    }

    private var extras: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AUSSERDEM")
                .font(.system(size: 10.5, weight: .heavy, design: .rounded))
                .tracking(1.6)
                .foregroundStyle(Theme.inkFaint)

            VStack(alignment: .leading, spacing: 10) {
                bullet("Fenster", "Dasselbe Tool mit mehr Platz und Verlauf. Ein Eintrag im "
                     + "Verlauf angeklickt übernimmt die Eingabe wieder.")
                bullet("Menüleiste", "Rechtsklick aufs Icon: als Fenster öffnen, bei "
                     + "Anmeldung starten, beenden.")
                bullet("Terminal", "QuickRNG --roll \"2d6\" gibt das Ergebnis direkt aus.")
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 10).fill(Theme.fill.opacity(0.8)))
        }
    }

    private func bullet(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.ink)
            Text(body)
                .font(.system(size: 12.5, design: .rounded))
                .foregroundStyle(Theme.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
