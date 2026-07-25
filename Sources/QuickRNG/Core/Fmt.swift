import Foundation

/// Locale-aware formatting helpers, shared by the parser labels and the roll results.
enum Fmt {
    private static let intFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        return f
    }()

    private static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yy"
        return f
    }()

    private static let fullDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate("EEE d MMM yyyy")
        return f
    }()

    static func int(_ v: Int) -> String {
        intFormatter.string(from: NSNumber(value: v)) ?? "\(v)"
    }

    static func double(_ v: Double, _ decimals: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = decimals
        f.maximumFractionDigits = decimals
        return f.string(from: NSNumber(value: v)) ?? "\(v)"
    }

    static func shortDate(_ d: Date) -> String { shortDateFormatter.string(from: d) }
    static func fullDate(_ d: Date) -> String { fullDateFormatter.string(from: d) }
}
