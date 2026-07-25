import SwiftUI
import AppKit

extension NSColor {
    /// A colour that resolves itself per appearance — so light mode is a real
    /// design, not the dark one with the lights turned up.
    static func dynamic(light: NSColor, dark: NSColor) -> NSColor {
        NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? dark : light
        }
    }

    convenience init(hex: UInt32) {
        self.init(srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }
}

enum Theme {
    // MARK: - Accents
    //
    // Each roll type gets its own accent, so you can tell at a glance what the
    // app thought you meant. The light variants are darkened and saturated —
    // the dark-mode mint is invisible on a white sheet.

    static func accentNS(_ kind: RollKind?) -> NSColor {
        switch kind {
        case .number:  return .dynamic(light: NSColor(hex: 0x00875A), dark: NSColor(hex: 0x6BFABD))
        case .list:    return .dynamic(light: NSColor(hex: 0x6337D6), dark: NSColor(hex: 0xCCBAFF))
        case .dice:    return .dynamic(light: NSColor(hex: 0xA96A00), dark: NSColor(hex: 0xFFD666))
        case .date:    return .dynamic(light: NSColor(hex: 0x0B62C4), dark: NSColor(hex: 0x99CFFF))
        case .coin:    return .dynamic(light: NSColor(hex: 0xB32C82), dark: NSColor(hex: 0xFFAAD9))
        case .shuffle: return .dynamic(light: NSColor(hex: 0x00806F), dark: NSColor(hex: 0x59F5DE))
        case nil:      return .dynamic(light: NSColor(hex: 0x6B7280), dark: NSColor(hex: 0xB8BDC9))
        }
    }

    static func accent(_ kind: RollKind?) -> Color { Color(nsColor: accentNS(kind)) }

    static func glyph(_ kind: RollKind?) -> String {
        switch kind {
        case .number:  return "number"
        case .list:    return "list.bullet"
        case .dice:    return "die.face.5"
        case .date:    return "calendar"
        case .coin:    return "circle.circle"
        case .shuffle: return "shuffle"
        case nil:      return "questionmark"
        }
    }

    // MARK: - Ink
    //
    // Deliberately high-contrast at every level — mid-grey on mid-grey is
    // unreadable at a glance, and glancing is the entire point of this app.

    private static func ink(_ lightAlpha: CGFloat, _ darkAlpha: CGFloat) -> Color {
        Color(nsColor: .dynamic(light: NSColor.black.withAlphaComponent(lightAlpha),
                                dark: NSColor.white.withAlphaComponent(darkAlpha)))
    }

    static let ink       = ink(0.92, 0.97)   // input text
    static let inkStrong = ink(0.82, 0.88)   // history entries
    static let inkMuted  = ink(0.62, 0.70)   // secondary lines
    static let inkFaint  = ink(0.53, 0.56)   // labels, hints, placeholders

    static let placeholderNS = NSColor.dynamic(light: NSColor.black.withAlphaComponent(0.36),
                                               dark: NSColor.white.withAlphaComponent(0.40))
    static let inputNS = NSColor.dynamic(light: NSColor.black.withAlphaComponent(0.92),
                                         dark: NSColor.white.withAlphaComponent(0.97))

    // MARK: - Surfaces

    /// Tint laid over the blur so type has something solid to sit on.
    static let surface = Color(nsColor: .dynamic(light: NSColor(hex: 0xF7F8FA).withAlphaComponent(0.82),
                                                 dark: NSColor(hex: 0x0E1014).withAlphaComponent(0.88)))
    /// Recessed fill — the input well, the cheat sheet, key caps.
    static let fill = Color(nsColor: .dynamic(light: NSColor.black.withAlphaComponent(0.055),
                                              dark: NSColor.white.withAlphaComponent(0.085)))
    static let fillStrong = Color(nsColor: .dynamic(light: NSColor.black.withAlphaComponent(0.09),
                                                    dark: NSColor.white.withAlphaComponent(0.13)))
    /// Hairline borders.
    static let hairline = Color(nsColor: .dynamic(light: NSColor.black.withAlphaComponent(0.13),
                                                  dark: NSColor.white.withAlphaComponent(0.13)))
    static let emptyResult = Color(nsColor: .dynamic(light: NSColor.black.withAlphaComponent(0.14),
                                                     dark: NSColor.white.withAlphaComponent(0.20)))

    /// Big results deserve big type; long ones have to give way.
    static func resultSize(for text: String, base: CGFloat) -> CGFloat {
        let longestLine = text.split(separator: "\n").map(\.count).max() ?? text.count
        switch longestLine {
        case ...6:  return base
        case ...11: return base * 0.80
        case ...18: return base * 0.62
        case ...30: return base * 0.46
        default:    return base * 0.36
        }
    }

    /// Menu bar icon. Hand-drawn rather than an SF Symbol — `die.face.5` renders
    /// hairline-thin and undersized next to every other icon up there. Template
    /// image, so macOS inverts it for light and dark menu bars by itself.
    static func statusIcon() -> NSImage {
        let side: CGFloat = 18
        let image = NSImage(size: NSSize(width: side, height: side), flipped: false) { _ in
            NSColor.black.setStroke()
            NSColor.black.setFill()

            let body = NSRect(x: 1.4, y: 1.4, width: side - 2.8, height: side - 2.8)
            let frame = NSBezierPath(roundedRect: body, xRadius: 4.8, yRadius: 4.8)
            frame.lineWidth = 2.0
            frame.stroke()

            let pip: CGFloat = 3.0
            for (fx, fy) in [(0.27, 0.73), (0.5, 0.5), (0.73, 0.27)] {
                let cx = body.minX + body.width * fx
                let cy = body.minY + body.height * fy
                NSBezierPath(ovalIn: NSRect(x: cx - pip / 2, y: cy - pip / 2,
                                            width: pip, height: pip)).fill()
            }
            return true
        }
        image.isTemplate = true
        return image
    }
}

/// The frosted backdrop behind the panel and the window.
struct VisualEffect: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .menu

    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = material
        v.blendingMode = .behindWindow
        v.state = .active
        return v
    }

    func updateNSView(_ v: NSVisualEffectView, context: Context) { v.material = material }
}
