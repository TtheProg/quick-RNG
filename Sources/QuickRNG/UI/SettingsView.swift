import SwiftUI

/// Everything that is a setting, in one place. It used to live at the bottom of
/// the Anleitung, where nobody scrolls to.
struct SettingsView: View {
    @Environment(\.colorScheme) private var scheme
    @State private var launchAtLogin = LoginItem.isEnabled

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("EINSTELLUNGEN")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(Theme.inkFaint)
                    Text("Quick RNG")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.ink)
                }

                ShortcutRecorder()

                row {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Bei Anmeldung starten")
                            .font(.system(size: 12.5, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.ink)
                        Text("Damit das Icon nach einem Neustart wieder da ist.")
                            .font(.system(size: 11.5, design: .rounded))
                            .foregroundStyle(Theme.inkMuted)
                    }
                    Spacer(minLength: 12)
                    Toggle("", isOn: $launchAtLogin)
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .onChange(of: launchAtLogin) { _, _ in
                            LoginItem.toggle()
                            launchAtLogin = LoginItem.isEnabled
                        }
                }

                Button { GuideWindowController.shared.show() } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Anleitung öffnen")
                            .font(.system(size: 12.5, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(Theme.accent(.number))
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)
            }
            .padding(26)
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
        .onAppear { launchAtLogin = LoginItem.isEnabled }
    }

    private func row<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        HStack(spacing: 12, content: content)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 10).fill(Theme.fill.opacity(0.8)))
    }
}
