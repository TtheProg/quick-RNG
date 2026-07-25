import SwiftUI

/// The Anleitung. Reachable from the `?` in the panel and in the window — the
/// syntax is guessable but not discoverable, so it needs a home.
///
/// Split into sections rather than one long scroll: as a single column it grew
/// taller than a small display, and a window taller than the screen loses its
/// title bar off the bottom.
struct GuideView: View {
    @ObservedObject private var hotKeys = HotKeyManager.shared
    @Environment(\.colorScheme) private var scheme
    @State private var section: Section = .start

    enum Section: String, CaseIterable, Identifiable {
        case start, inputs, keys, more
        var id: String { rawValue }

        var title: String {
            switch self {
            case .start:  return "Schnellstart"
            case .inputs: return "Eingaben"
            case .keys:   return "Tasten"
            case .more:   return "Mehr"
            }
        }

        var symbol: String {
            switch self {
            case .start:  return "bolt"
            case .inputs: return "text.cursor"
            case .keys:   return "keyboard"
            case .more:   return "ellipsis.circle"
            }
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            rail
            Divider().overlay(Theme.hairline.opacity(0.6))
            ScrollView {
                content
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(minWidth: 540, minHeight: 340)
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

    // MARK: - Rail

    private var rail: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("ANLEITUNG")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(1.8)
                .foregroundStyle(Theme.inkFaint)
                .padding(.horizontal, 10)
                .padding(.top, 30)
                .padding(.bottom, 12)

            ForEach(Section.allCases) { s in
                railItem(s)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 14)
        .frame(width: 168, alignment: .leading)
    }

    private func railItem(_ s: Section) -> some View {
        let selected = section == s
        return Button { section = s } label: {
            HStack(spacing: 8) {
                Image(systemName: s.symbol)
                    .font(.system(size: 11, weight: .semibold))
                    .frame(width: 15)
                Text(s.title)
                    .font(.system(size: 12.5, weight: selected ? .semibold : .medium, design: .rounded))
                Spacer(minLength: 0)
            }
            .foregroundStyle(selected ? Theme.accent(.number) : Theme.inkMuted)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(selected ? Theme.accent(.number).opacity(0.14) : .clear)
            )
            .contentShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch section {
        case .start:  intro
        case .inputs: table(inputs)
        case .keys:   keysSection
        case .more:   extras
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ein Feld für alles")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.ink)
            Text("Icon anklicken\(hotKeys.shortcut.map { " oder \($0.display) drücken" } ?? "") — der Cursor steht schon im Feld. "
               + "Tippen, Return, fertig. Danach ist der Text komplett markiert: "
               + "nochmal Return würfelt neu, Tippen überschreibt.\n\n"
               + "Was gewürfelt wird, leitet Quick RNG aus deiner Eingabe ab. "
               + "Der Chip oben rechts zeigt schon beim Tippen, wie sie verstanden wurde — "
               + "passt er nicht, siehst du das, bevor du Return drückst.\n\n"
               + "Die Akzentfarbe wechselt mit: Zahlen mint, Listen violett, Würfel "
               + "bernstein, Daten blau, Münze pink, Mischen türkis.")
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

    /// The shortcut row follows the actual setting — a list that still claims
    /// ⇧⌘R after you've changed it is worse than no list.
    private var keys: [(String, String)] {
        [
            ("Return", "würfeln — und gleich nochmal für einen neuen Wurf"),
            ("↑ / ↓", "durch frühere Eingaben blättern"),
            ("esc", "Panel schließen — und dieses Fenster hier"),
            (hotKeys.shortcut?.display ?? "—",
             hotKeys.shortcut == nil
                ? "kein Kurzbefehl gesetzt — in den Einstellungen (⌘,)"
                : "Panel von überall öffnen — nochmal drücken schließt es"),
        ]
    }

    private var keysSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            table(keys)
            Button { SettingsWindowController.shared.show() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Kurzbefehl in den Einstellungen ändern")
                        .font(.system(size: 12.5, weight: .medium, design: .rounded))
                }
                .foregroundStyle(Theme.accent(.number))
            }
            .buttonStyle(.plain)
        }
    }

    private func table(_ entries: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            ForEach(entries, id: \.0) { entry in
                HStack(alignment: .firstTextBaseline, spacing: 14) {
                    Text(entry.0)
                        .font(.system(size: 12.5, weight: .medium, design: .monospaced))
                        .foregroundStyle(Theme.ink)
                        .frame(width: 176, alignment: .leading)
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

    private var extras: some View {
        VStack(alignment: .leading, spacing: 10) {
            bullet("Fenster", "Dasselbe Tool mit mehr Platz und Verlauf. Ein Eintrag im "
                 + "Verlauf angeklickt übernimmt die Eingabe wieder.")
            bullet("Menüleiste", "Rechtsklick aufs Icon: als Fenster öffnen, Anleitung, "
                 + "Einstellungen, beenden.")
            bullet("Einstellungen", "⌘, — Kurzbefehl und „bei Anmeldung starten\".")
            bullet("Terminal", "QuickRNG --roll \"2d6\" gibt das Ergebnis direkt aus.")
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.fill.opacity(0.8)))
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
