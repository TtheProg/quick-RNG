import SwiftUI

/// The standalone window: same roller, more room, plus the verlauf and a cheat sheet.
struct WindowView: View {
    @ObservedObject var state = AppState.shared
    @State private var showSyntax = false
    @Environment(\.colorScheme) private var scheme

    private var kind: RollKind? { state.result?.kind ?? state.preview?.kind }
    private var accent: Color { Theme.accent(kind) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("QUICK RNG")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(Theme.inkFaint)
                    Spacer()
                    KindChip(request: state.preview)
                    IconButton(symbol: "questionmark.circle", tooltip: "Anleitung", size: 16) {
                        GuideWindowController.shared.show()
                    }
                    .padding(.trailing, -7)
                }
                .padding(.top, 24)

                ResultView(result: state.result, baseSize: 78)
                    .frame(minHeight: 96, alignment: .topLeading)

                inputRow
            }
            .padding(.horizontal, 26)
            .padding(.bottom, 18)

            Divider().overlay(Theme.hairline.opacity(0.6))

            historySection
        }
        .frame(minWidth: 460, minHeight: 560)
        .background(
            ZStack {
                VisualEffect(material: .underWindowBackground)
                Theme.surface
                LinearGradient(colors: [accent.opacity(scheme == .dark ? 0.16 : 0.13), .clear],
                               startPoint: .top, endPoint: .center)
            }
            .ignoresSafeArea()
        )
        .animation(.easeOut(duration: 0.3), value: kind)
        .onAppear { state.focusInput() }
    }

    private var inputRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 11) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(accent)
                RollField(
                    text: $state.input,
                    placeholder: "100 · rot, grün, blau · 2d6 · 1.1.26 – 31.12.26",
                    font: .monospacedSystemFont(ofSize: 16, weight: .medium),
                    accent: Theme.accentNS(kind),
                    focusToken: state.focusToken,
                    selectAllToken: state.selectAllToken,
                    onSubmit: { state.roll() },
                    onEscape: { state.clear() },
                    onUp: { state.recallPrevious() },
                    onDown: { state.recallNext() }
                )
                .frame(height: 22)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(Theme.fill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .stroke(accent.opacity(0.5), lineWidth: 1)
                    )
            )

            HStack(spacing: 8) {
                Button { withAnimation(.easeOut(duration: 0.2)) { showSyntax.toggle() } } label: {
                    HStack(spacing: 4) {
                        Image(systemName: showSyntax ? "chevron.down" : "chevron.right")
                            .font(.system(size: 8, weight: .bold))
                        Text("was kann ich eingeben?")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(Theme.inkFaint)
                }
                .buttonStyle(.plain)

                Text("·").foregroundStyle(Theme.inkFaint)

                Button { GuideWindowController.shared.show() } label: {
                    Text("ganze Anleitung")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.inkFaint)
                }
                .buttonStyle(.plain)
            }

            if showSyntax { syntaxSheet }
        }
    }

    private let syntax: [(String, String)] = [
        ("100", "1 bis 100"),
        ("3 - 9", "Ganzzahl im Bereich"),
        ("1.5 - 2.5", "Kommazahl im Bereich"),
        ("rot, grün, blau", "eine Option"),
        ("ja / nein", "eine Option"),
        ("3x a, b, c, d", "drei verschiedene"),
        ("shuffle a, b, c", "ganze Reihenfolge"),
        ("2d6  ·  d20  ·  3w8+2", "Würfel"),
        ("1.1.26 - 31.12.26", "Datum im Zeitraum"),
        ("münze", "Kopf oder Zahl"),
    ]

    private var syntaxSheet: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(syntax, id: \.0) { item in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(item.0)
                        .font(.system(size: 12.5, design: .monospaced))
                        .foregroundStyle(Theme.ink)
                        .frame(width: 186, alignment: .leading)
                    Text(item.1)
                        .font(.system(size: 12.5, design: .rounded))
                        .foregroundStyle(Theme.inkMuted)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 9).fill(Theme.fill.opacity(0.7)))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("VERLAUF")
                    .font(.system(size: 10.5, weight: .heavy, design: .rounded))
                    .tracking(1.6)
                    .foregroundStyle(Theme.inkFaint)
                Spacer()
                if !state.history.isEmpty {
                    Button("leeren") { withAnimation { state.history.removeAll() } }
                        .buttonStyle(.plain)
                        .font(.system(size: 11.5, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.inkFaint)
                }
            }
            .padding(.horizontal, 26)
            .padding(.top, 14)
            .padding(.bottom, 8)

            if state.history.isEmpty {
                Text("Noch nichts gewürfelt.")
                    .font(.system(size: 12.5, design: .rounded))
                    .foregroundStyle(Theme.inkFaint)
                    .padding(.horizontal, 26)
                Spacer(minLength: 0)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(state.history) { row($0) }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 14)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func row(_ r: RollResult) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Theme.accent(r.kind))
                .frame(width: 5, height: 5)
            Text(r.primary.replacingOccurrences(of: "\n", with: "  ·  "))
                .font(.system(size: 13.5, weight: .medium, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Theme.inkStrong)
                .lineLimit(1)
            Spacer(minLength: 8)
            Text(r.input.isEmpty ? "1–100" : r.input)
                .font(.system(size: 11.5, design: .monospaced))
                .foregroundStyle(Theme.inkFaint)
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: 140, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .contentShape(Rectangle())
        .onTapGesture {
            state.input = r.input
            state.focusInput()
        }
    }
}
