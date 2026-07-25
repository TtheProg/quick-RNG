import SwiftUI

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var input: String = ""
    @Published var result: RollResult?
    @Published var history: [RollResult] = []
    /// Bumped after each roll so the text field re-selects everything.
    @Published var selectAllToken: Int = 0
    /// Bumped when the panel opens so the text field grabs first responder.
    @Published var focusToken: Int = 0

    private var inputHistory: [String] = []
    private var historyCursor: Int = -1

    private let inputHistoryKey = "quickrng.inputHistory"

    private init() {
        inputHistory = UserDefaults.standard.stringArray(forKey: inputHistoryKey) ?? []
    }

    /// Live preview of what the current text will do, without rolling.
    var preview: Request? { Parser.parse(input) }

    func roll() {
        guard let request = preview else { return }
        let result = Roller.roll(request, input: input)
        self.result = result
        history.insert(result, at: 0)
        if history.count > 100 { history.removeLast(history.count - 100) }
        remember(input)
        selectAllToken &+= 1
    }

    func focusInput() {
        focusToken &+= 1
        selectAllToken &+= 1
        historyCursor = -1
    }

    func clear() {
        input = ""
        result = nil
        historyCursor = -1
    }

    // MARK: - ↑/↓ through previous inputs

    func recallPrevious() {
        guard !inputHistory.isEmpty else { return }
        historyCursor = min(historyCursor + 1, inputHistory.count - 1)
        input = inputHistory[historyCursor]
        selectAllToken &+= 1
    }

    func recallNext() {
        guard historyCursor >= 0 else { return }
        historyCursor -= 1
        input = historyCursor >= 0 ? inputHistory[historyCursor] : ""
        selectAllToken &+= 1
    }

    private func remember(_ value: String) {
        let v = value.trimmingCharacters(in: .whitespacesAndNewlines)
        historyCursor = -1
        guard !v.isEmpty else { return }
        inputHistory.removeAll { $0 == v }
        inputHistory.insert(v, at: 0)
        if inputHistory.count > 30 { inputHistory.removeLast(inputHistory.count - 30) }
        UserDefaults.standard.set(inputHistory, forKey: inputHistoryKey)
    }
}
