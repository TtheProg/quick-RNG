import Foundation

struct RollResult: Identifiable, Equatable {
    let id = UUID()
    /// The headline — the thing the user actually came for.
    let primary: String
    /// The small line underneath: what it was drawn from.
    let secondary: String?
    let kind: RollKind
    let input: String
    let date: Date
    /// Set for plain integer rolls so the result can slot-machine into place.
    let scrambleRange: ClosedRange<Int>?

    static func == (a: RollResult, b: RollResult) -> Bool { a.id == b.id }
}

enum Roller {

    static func roll(_ request: Request, input: String) -> RollResult {
        switch request {

        case .ints(let range):
            let v = Int.random(in: range)
            return RollResult(primary: Fmt.int(v),
                              secondary: "aus \(Fmt.int(range.lowerBound))–\(Fmt.int(range.upperBound))",
                              kind: .number, input: input, date: Date(),
                              scrambleRange: range)

        case .doubles(let range, let decimals):
            let v = Double.random(in: range)
            return RollResult(primary: Fmt.double(v, decimals),
                              secondary: "aus \(Fmt.double(range.lowerBound, decimals))–\(Fmt.double(range.upperBound, decimals))",
                              kind: .number, input: input, date: Date(),
                              scrambleRange: nil)

        case .list(let items, let pick):
            if pick <= 1 {
                let v = items.randomElement() ?? ""
                return RollResult(primary: v,
                                  secondary: "aus \(items.count) Optionen",
                                  kind: .list, input: input, date: Date(), scrambleRange: nil)
            }
            let chosen = Array(items.shuffled().prefix(pick))
            return RollResult(primary: chosen.joined(separator: "  ·  "),
                              secondary: "\(pick) aus \(items.count) Optionen",
                              kind: .list, input: input, date: Date(), scrambleRange: nil)

        case .shuffle(let items):
            let order = items.shuffled()
            let text = order.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
            return RollResult(primary: text,
                              secondary: "\(items.count) gemischt",
                              kind: .shuffle, input: input, date: Date(), scrambleRange: nil)

        case .dice(let count, let sides, let modifier):
            let rolls = (0..<count).map { _ in Int.random(in: 1...sides) }
            let total = rolls.reduce(0, +) + modifier
            let modText = modifier == 0 ? "" : (modifier > 0 ? " + \(modifier)" : " − \(abs(modifier))")
            let detail = count == 1 && modifier == 0
                ? "1d\(sides)"
                : "\(count)d\(sides)\(modText)  ·  " + rolls.map(String.init).joined(separator: " + ")
            return RollResult(primary: Fmt.int(total),
                              secondary: detail,
                              kind: .dice, input: input, date: Date(),
                              scrambleRange: (count + modifier)...(count * sides + modifier))

        case .dates(let range):
            let cal = Calendar.current
            let days = max(0, cal.dateComponents([.day], from: range.lowerBound, to: range.upperBound).day ?? 0)
            let offset = Int.random(in: 0...days)
            let d = cal.date(byAdding: .day, value: offset, to: range.lowerBound) ?? range.lowerBound
            return RollResult(primary: Fmt.fullDate(d),
                              secondary: "aus \(Fmt.int(days + 1)) Tagen",
                              kind: .date, input: input, date: Date(), scrambleRange: nil)

        case .coin:
            return RollResult(primary: Bool.random() ? "Kopf" : "Zahl",
                              secondary: "Münzwurf",
                              kind: .coin, input: input, date: Date(), scrambleRange: nil)
        }
    }
}
