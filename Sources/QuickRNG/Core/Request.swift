import Foundation

/// What kind of randomness the user asked for. Drives the accent colour and the chip label.
enum RollKind: String {
    case number, list, dice, date, coin, shuffle
}

/// A parsed, ready-to-roll request. `Parser` turns raw text into one of these,
/// `Roller` turns one of these into a `RollResult`.
enum Request {
    case ints(ClosedRange<Int>)
    case doubles(ClosedRange<Double>, decimals: Int)
    case list([String], pick: Int)
    case shuffle([String])
    case dice(count: Int, sides: Int, modifier: Int)
    case dates(ClosedRange<Date>)
    case coin

    var kind: RollKind {
        switch self {
        case .ints, .doubles: return .number
        case .list:           return .list
        case .shuffle:        return .shuffle
        case .dice:           return .dice
        case .dates:          return .date
        case .coin:           return .coin
        }
    }

    /// Short live-preview label shown in the chip while typing.
    var label: String {
        switch self {
        case .ints(let r):
            return "\(Fmt.int(r.lowerBound))–\(Fmt.int(r.upperBound))"
        case .doubles(let r, let d):
            return "\(Fmt.double(r.lowerBound, d))–\(Fmt.double(r.upperBound, d))"
        case .list(let items, let pick):
            return pick > 1 ? "\(pick) aus \(items.count)" : "\(items.count) Optionen"
        case .shuffle(let items):
            return "mischen · \(items.count)"
        case .dice(let c, let s, let m):
            let mod = m == 0 ? "" : (m > 0 ? "+\(m)" : "\(m)")
            return "\(c)d\(s)\(mod)"
        case .dates(let r):
            return "\(Fmt.shortDate(r.lowerBound)) – \(Fmt.shortDate(r.upperBound))"
        case .coin:
            return "Münzwurf"
        }
    }
}
