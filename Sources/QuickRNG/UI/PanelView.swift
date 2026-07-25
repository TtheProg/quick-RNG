import SwiftUI

/// The thing that drops out of the menu bar.
struct PanelView: View {
    @ObservedObject var state = AppState.shared
    @ObservedObject private var hotKeys = HotKeyManager.shared
    @Environment(\.colorScheme) private var scheme
    @State private var menuHovering = false
    var onHeightChange: (CGFloat) -> Void = { _ in }

    private var kind: RollKind? { state.result?.kind ?? state.preview?.kind }
    private var accent: Color { Theme.accent(kind) }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            ResultView(result: state.result, baseSize: 54)
            inputRow
            footer
        }
        .padding(18)
        .background(
            ZStack {
                VisualEffect(material: .menu)
                Theme.surface
                LinearGradient(colors: [accent.opacity(scheme == .dark ? 0.16 : 0.13), .clear],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Theme.hairline, lineWidth: 0.75)
        )
        .animation(.easeOut(duration: 0.25), value: kind)
        .background(GeometryReader { g in
            Color.clear
                .onAppear { onHeightChange(g.size.height) }
                .onChange(of: g.size.height) { _, h in onHeightChange(h) }
        })
    }

    private var header: some View {
        HStack {
            Text("QUICK RNG")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(1.8)
                .foregroundStyle(Theme.inkFaint)
            Spacer(minLength: 8)
            KindChip(request: state.preview)
        }
    }

    private var inputRow: some View {
        HStack(spacing: 10) {
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(accent)
            RollField(
                text: $state.input,
                placeholder: "100 · a,b,c · 2d6 · Datum",
                font: .monospacedSystemFont(ofSize: 15, weight: .medium),
                accent: Theme.accentNS(kind),
                focusToken: state.focusToken,
                selectAllToken: state.selectAllToken,
                onSubmit: { state.roll() },
                onEscape: { PanelController.shared.hide() },
                onUp: { state.recallPrevious() },
                onDown: { state.recallNext() }
            )
            .frame(height: 22)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Theme.fill)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(accent.opacity(0.5), lineWidth: 1)
                )
        )
    }

    private var footer: some View {
        HStack(spacing: 12) {
            hint("return", "würfeln")
            hint("↑↓", "verlauf")
            Spacer(minLength: 4)
            IconButton(symbol: "questionmark.circle", tooltip: "Anleitung") {
                GuideWindowController.shared.show()
                PanelController.shared.hide()
            }
            .padding(.trailing, -8)   // the hit areas already carry the spacing
            IconButton(symbol: "macwindow", tooltip: "Als Fenster öffnen") {
                WindowController.shared.show()
                PanelController.shared.hide()
            }
            .padding(.trailing, -8)

            Menu {
                Button("Als Fenster öffnen") { WindowController.shared.show(); PanelController.shared.hide() }
                Button("Anleitung") { GuideWindowController.shared.show(); PanelController.shared.hide() }
                Toggle("Bei Anmeldung starten", isOn: Binding(
                    get: { LoginItem.isEnabled },
                    set: { _ in LoginItem.toggle() }
                ))
                Divider()
                Text(shortcutHint)
                Button("Quick RNG beenden") { NSApp.terminate(nil) }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 15, weight: .semibold))
                    .iconHitArea(hovering: menuHovering)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .frame(width: 28, height: 28)
            .foregroundStyle(menuHovering ? Theme.inkStrong : Theme.inkFaint)
            .onHover { menuHovering = $0 }
            .animation(.easeOut(duration: 0.12), value: menuHovering)
            .tooltip("Mehr")
        }
        .zIndex(1)   // tooltips must draw over the input row above them
    }

    private var shortcutHint: String {
        hotKeys.shortcut.map { "Überall: \($0.display)" } ?? "Kein Kurzbefehl"
    }

    private func hint(_ key: String, _ label: String) -> some View {
        HStack(spacing: 5) {
            Text(key)
                .font(.system(size: 10.5, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.inkMuted)
                .padding(.horizontal, 5).padding(.vertical, 2)
                .background(RoundedRectangle(cornerRadius: 4).fill(Theme.fillStrong))
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.inkFaint)
        }
    }
}
