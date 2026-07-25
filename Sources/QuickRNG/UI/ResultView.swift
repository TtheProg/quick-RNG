import SwiftUI

/// The headline. Integer results tumble through a few random values before
/// landing — it takes 240ms and it's the reason the app feels alive.
struct ResultView: View {
    let result: RollResult?
    let baseSize: CGFloat

    @State private var scrambled: String?
    @State private var settled = true
    @Environment(\.colorScheme) private var scheme

    private var accent: Color { Theme.accent(result?.kind) }

    var body: some View {
        let text = scrambled ?? result?.primary ?? "—"
        // Size from the *settled* value, never from the scramble frames: a roll
        // out of 24000 tumbles through 3- and 5-digit numbers, and sizing on
        // those would resize the type — and with it the whole panel — mid-roll.
        let size = Theme.resultSize(for: result?.primary ?? "—", base: baseSize)
        VStack(alignment: .leading, spacing: 8) {
            Text(text)
                .font(.system(size: size, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(result == nil ? Theme.emptyResult : accent)
                .shadow(color: accent.opacity(result == nil ? 0 : (scheme == .dark ? 0.45 : 0.18)),
                        radius: scheme == .dark ? 22 : 14, y: 2)
                .lineLimit(6)
                .minimumScaleFactor(0.4)
                .fixedSize(horizontal: false, vertical: true)
                .frame(minHeight: size * 1.2, alignment: .topLeading)
                .contentTransition(.numericText())
                .scaleEffect(settled ? 1 : 1.05, anchor: .leading)
                .animation(.spring(response: 0.28, dampingFraction: 0.6), value: settled)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(result?.secondary ?? " ")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.inkMuted)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .animation(.easeOut(duration: 0.18), value: result?.id)
        .onChange(of: result?.id) { _, _ in scramble() }
    }

    private func scramble() {
        guard let range = result?.scrambleRange, range.count > 1 else {
            settled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { settled = true }
            return
        }
        settled = false
        let ticks = 7
        for i in 0..<ticks {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.032) {
                scrambled = Fmt.int(Int.random(in: range))
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(ticks) * 0.032) {
            scrambled = nil
            settled = true
        }
    }
}

/// The little pill that tells you how your text was understood, live as you type.
struct KindChip: View {
    let request: Request?

    var body: some View {
        let kind = request?.kind
        let accent = Theme.accent(kind)
        HStack(spacing: 5) {
            Image(systemName: Theme.glyph(kind))
                .font(.system(size: 10, weight: .bold))
            Text(request?.label ?? "versteh ich nicht")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .lineLimit(1)
        }
        .foregroundStyle(accent.opacity(request == nil ? 0.7 : 1))
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(
            Capsule().fill(accent.opacity(0.15))
                .overlay(Capsule().stroke(accent.opacity(0.38), lineWidth: 0.75))
        )
        .animation(.easeOut(duration: 0.15), value: request?.label)
    }
}
