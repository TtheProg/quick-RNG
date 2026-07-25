import Foundation

/// Turns whatever the user typed into a `Request`.
///
/// Everything is one text field, so the parser guesses the intent. Order matters —
/// the more specific a pattern is, the earlier it gets a chance:
///
///   (leer)                  → 1–100
///   100                     → 1–100
///   3-9 · 3..9 · 3 bis 9    → Ganzzahl im Bereich
///   1.5 - 2.5               → Kommazahl im Bereich
///   rot, grün, blau         → eine Option
///   ja/nein                 → eine Option
///   3x a, b, c, d           → drei verschiedene Optionen
///   shuffle a, b, c         → komplette Reihenfolge
///   2d6 · d20 · 3w8+2       → Würfel
///   01.01.2026 - 31.12.2026 → Datum im Zeitraum
///   coin · münze            → Kopf oder Zahl
enum Parser {

    static func parse(_ raw: String) -> Request? {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return .ints(1...100) }
        let low = s.lowercased()

        if coinWords.contains(low) { return .coin }

        if let rest = strip(prefixes: shuffleWords, from: low, original: s) {
            let items = splitList(rest)
            if items.count >= 2 { return .shuffle(items) }
        }

        if let (n, rest) = pickPrefix(s) {
            let items = splitList(rest)
            if items.count >= 2 { return .list(items, pick: min(n, items.count)) }
        }

        if let dice = parseDice(low) { return dice }

        // A lone date is not a roll — but it must not be mistaken for a "/"-separated list.
        let isSingleDate = parseDate(s) != nil

        // Ranges: dates win over numbers, and every possible split point is tried
        // so that "2026-01-01 - 2026-12-31" survives its own hyphens.
        let splits = candidateSplits(s)
        for (l, r) in splits {
            if let a = parseDate(l), let b = parseDate(r) {
                return .dates(min(a, b)...max(a, b))
            }
        }
        for (l, r) in splits {
            guard let a = number(l), let b = number(r) else { continue }
            if isIntegerLiteral(l) && isIntegerLiteral(r), let ai = Int(exactly: a.rounded()), let bi = Int(exactly: b.rounded()) {
                return .ints(min(ai, bi)...max(ai, bi))
            }
            let dec = max(decimals(l), decimals(r), 1)
            return .doubles(min(a, b)...max(a, b), decimals: dec)
        }

        if !isSingleDate {
            let items = splitList(s)
            if items.count >= 2 { return .list(items, pick: 1) }
        }

        if isIntegerLiteral(s), let i = Int(normalized(s)) {
            return .ints(i >= 1 ? 1...i : i...0)
        }
        if let d = number(s) {
            return .doubles(min(0, d)...max(0, d), decimals: max(decimals(s), 2))
        }
        return nil
    }

    // MARK: - Vocabulary

    private static let coinWords: Set<String> = [
        "coin", "coinflip", "flip", "toss", "münze", "muenze", "münzwurf", "muenzwurf",
        "kopf oder zahl", "heads or tails", "wirf"
    ]
    private static let shuffleWords = ["shuffle", "mische", "misch", "mix", "reihenfolge", "order"]
    private static let listSeparators: [Character] = [",", ";", "|", "/"]

    // MARK: - Pieces

    private static func strip(prefixes: [String], from low: String, original: String) -> String? {
        for p in prefixes where low.hasPrefix(p + " ") {
            return String(original.dropFirst(p.count)).trimmingCharacters(in: .whitespaces)
        }
        return nil
    }

    /// "3x a,b,c" / "3 aus a,b,c" / "2 of a,b,c"
    private static func pickPrefix(_ s: String) -> (Int, String)? {
        let pattern = #"^\s*(\d+)\s*(?:x|×|of|aus|von)\b\s*(.+)$"#
        guard let m = firstMatch(pattern, in: s, options: [.caseInsensitive]),
              let n = Int(m[1]), n >= 1 else { return nil }
        return (n, m[2])
    }

    /// "2d6", "d20", "3w8+2"
    private static func parseDice(_ s: String) -> Request? {
        let pattern = #"^\s*(\d*)\s*[dw]\s*(\d+)\s*(?:([+-])\s*(\d+))?\s*$"#
        guard let m = firstMatch(pattern, in: s, options: [.caseInsensitive]),
              let sides = Int(m[2]), sides >= 2, sides <= 100_000 else { return nil }
        let count = m[1].isEmpty ? 1 : (Int(m[1]) ?? 1)
        guard count >= 1, count <= 500 else { return nil }
        var modifier = 0
        if !m[4].isEmpty, let v = Int(m[4]) { modifier = m[3] == "-" ? -v : v }
        return .dice(count: count, sides: sides, modifier: modifier)
    }

    private static func splitList(_ s: String) -> [String] {
        var best: [String] = []
        for sep in listSeparators {
            let parts = s.split(separator: sep, omittingEmptySubsequences: true)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            if parts.count > best.count { best = parts }
        }
        return best
    }

    /// Every plausible way to cut the string into two halves of a range.
    private static func candidateSplits(_ s: String) -> [(String, String)] {
        let separators = ["...", "..", "…", "–", "—", "->", "→", " to ", " bis ", " until ", " - ", "-"]
        var out: [(String, String)] = []
        for sep in separators {
            var search = s.startIndex..<s.endIndex
            while let r = s.range(of: sep, range: search) {
                let l = String(s[s.startIndex..<r.lowerBound]).trimmingCharacters(in: .whitespaces)
                let rr = String(s[r.upperBound...]).trimmingCharacters(in: .whitespaces)
                if !l.isEmpty && !rr.isEmpty { out.append((l, rr)) }
                guard r.upperBound < s.endIndex else { break }
                search = r.upperBound..<s.endIndex
            }
        }
        return out
    }

    // MARK: - Numbers

    private static func normalized(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: "'", with: "")
            .replacingOccurrences(of: "\u{202F}", with: "")
    }

    private static func isIntegerLiteral(_ s: String) -> Bool {
        firstMatch(#"^[+-]?\d+$"#, in: normalized(s), options: []) != nil
    }

    private static func number(_ s: String) -> Double? {
        let n = normalized(s)
        guard firstMatch(#"^[+-]?(\d+([.,]\d+)?|[.,]\d+)$"#, in: n, options: []) != nil else { return nil }
        return Double(n.replacingOccurrences(of: ",", with: "."))
    }

    private static func decimals(_ s: String) -> Int {
        let n = normalized(s)
        guard let dot = n.lastIndex(where: { $0 == "." || $0 == "," }) else { return 0 }
        return n.distance(from: n.index(after: dot), to: n.endIndex)
    }

    // MARK: - Dates

    private static let dateFormats = [
        "dd.MM.yyyy", "d.M.yyyy", "dd.MM.yy", "d.M.yy",
        "yyyy-MM-dd", "dd-MM-yyyy",
        "dd/MM/yyyy", "d/M/yyyy", "dd/MM/yy", "d/M/yy"
    ]

    static func parseDate(_ s: String) -> Date? {
        let t = s.trimmingCharacters(in: .whitespaces)
        // Cheap guard so bare numbers never sneak through a lenient formatter.
        guard t.rangeOfCharacter(from: CharacterSet(charactersIn: "./-")) != nil else { return nil }
        // Without this, "1.1.26" matches a yyyy pattern and lands in the year 26.
        let hasFourDigitYear = firstMatch(#"\d{4}"#, in: t, options: []) != nil
        for format in dateFormats {
            if format.contains("yyyy") != hasFourDigitYear { continue }
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.timeZone = .current
            f.isLenient = false
            f.dateFormat = format
            if let d = f.date(from: t) { return Calendar.current.startOfDay(for: d) }
        }
        return nil
    }

    // MARK: - Regex helper

    private static func firstMatch(_ pattern: String, in s: String, options: NSRegularExpression.Options) -> [String]? {
        guard let re = try? NSRegularExpression(pattern: pattern, options: options) else { return nil }
        let ns = s as NSString
        guard let m = re.firstMatch(in: s, range: NSRange(location: 0, length: ns.length)) else { return nil }
        return (0..<m.numberOfRanges).map { i in
            let r = m.range(at: i)
            return r.location == NSNotFound ? "" : ns.substring(with: r)
        }
    }
}
