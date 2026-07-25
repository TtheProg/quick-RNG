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
                        .offset(y: -26)
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
struct IconButton: View {
    let symbol: String
    let tooltip: String
    var size: CGFloat = 13
    let action: () -> Void

    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: size, weight: .semibold))
        }
        .buttonStyle(.plain)
        .foregroundStyle(hovering ? Theme.inkStrong : Theme.inkFaint)
        .onHover { hovering = $0 }
        .animation(.easeOut(duration: 0.12), value: hovering)
        .tooltip(tooltip)
    }
}
