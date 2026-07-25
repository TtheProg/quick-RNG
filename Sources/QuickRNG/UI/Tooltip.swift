import SwiftUI

/// A hover label for the icon buttons.
///
/// `.help()` relies on AppKit's tooltip machinery, which stays silent in a
/// non-activating panel belonging to a background app — exactly where these
/// buttons live. So the panel brings its own.
private struct TooltipModifier: ViewModifier {
    let text: String
    @State private var hovering = false

    func body(content: Content) -> some View {
        content
            .help(text)                     // keeps the accessibility label
            .onHover { hovering = $0 }
            .overlay(alignment: .top) {
                if hovering {
                    Text(text)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(1)
                        .fixedSize()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Theme.tooltipBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .stroke(Theme.hairline, lineWidth: 0.5)
                                )
                                .shadow(color: .black.opacity(0.22), radius: 6, y: 2)
                        )
                        .offset(y: -30)
                        .transition(.opacity)
                        .allowsHitTesting(false)
                }
            }
            .animation(.easeOut(duration: 0.12), value: hovering)
    }
}

extension View {
    func tooltip(_ text: String) -> some View { modifier(TooltipModifier(text: text)) }
}

/// An icon button that brightens on hover and explains itself.
///
/// The glyph is small by design, the target is not: `IconHitArea` gives every
/// one of these a 28pt square to be clicked in, which is roughly where a
/// pointer stops being fiddly.
struct IconButton: View {
    let symbol: String
    let tooltip: String
    var size: CGFloat = 15
    let action: () -> Void

    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: size, weight: .semibold))
                .iconHitArea(hovering: hovering)
        }
        .buttonStyle(.plain)
        .foregroundStyle(hovering ? Theme.inkStrong : Theme.inkFaint)
        .onHover { hovering = $0 }
        .animation(.easeOut(duration: 0.12), value: hovering)
        .tooltip(tooltip)
    }
}

extension View {
    /// A generous, hoverable click target around a small glyph.
    func iconHitArea(hovering: Bool) -> some View {
        frame(width: 28, height: 28)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(hovering ? Theme.fill : Color.clear)
            )
            .contentShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
    }
}
