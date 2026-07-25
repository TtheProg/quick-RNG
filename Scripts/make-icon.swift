#!/usr/bin/env swift
import AppKit

// Draws the app icon: a dark squircle with three mint pips on the diagonal —
// a die read at a glance, not a literal one.

let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "build/AppIcon.iconset"
try? FileManager.default.createDirectory(atPath: out, withIntermediateDirectories: true)

func draw(size S: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: S, height: S))
    image.lockFocus()
    let ctx = NSGraphicsContext.current!.cgContext
    ctx.setAllowsAntialiasing(true)

    // Squircle backdrop, inset like every other macOS icon.
    let inset = S * 0.085
    let rect = NSRect(x: inset, y: inset, width: S - inset * 2, height: S - inset * 2)
    let body = NSBezierPath(roundedRect: rect, xRadius: S * 0.225, yRadius: S * 0.225)
    body.addClip()

    let bg = NSGradient(colors: [
        NSColor(calibratedRed: 0.09, green: 0.10, blue: 0.13, alpha: 1),
        NSColor(calibratedRed: 0.14, green: 0.16, blue: 0.21, alpha: 1)
    ])!
    bg.draw(in: rect, angle: -60)

    // Accent bloom in the top-left.
    let bloom = NSGradient(colors: [
        NSColor(calibratedRed: 0.44, green: 0.92, blue: 0.72, alpha: 0.30),
        NSColor(calibratedRed: 0.44, green: 0.92, blue: 0.72, alpha: 0.0)
    ])!
    bloom.draw(in: rect, relativeCenterPosition: NSPoint(x: -0.55, y: 0.55))

    // Three pips on the diagonal, fading toward the corner.
    let pipR = S * 0.072
    let positions: [(CGFloat, CGFloat, CGFloat)] = [
        (0.32, 0.68, 1.0),
        (0.50, 0.50, 0.82),
        (0.68, 0.32, 0.55)
    ]
    for (fx, fy, alpha) in positions {
        let c = NSPoint(x: rect.minX + rect.width * fx, y: rect.minY + rect.height * fy)
        let dot = NSBezierPath(ovalIn: NSRect(x: c.x - pipR, y: c.y - pipR, width: pipR * 2, height: pipR * 2))
        NSColor(calibratedRed: 0.44, green: 0.92, blue: 0.72, alpha: alpha).setFill()
        dot.fill()
    }

    // Top highlight edge.
    NSColor.white.withAlphaComponent(0.10).setStroke()
    let edge = NSBezierPath(roundedRect: rect.insetBy(dx: 0.5, dy: 0.5), xRadius: S * 0.225, yRadius: S * 0.225)
    edge.lineWidth = max(1, S * 0.004)
    edge.stroke()

    image.unlockFocus()
    return image
}

for (size, name) in [(16, "16x16"), (32, "16x16@2x"), (32, "32x32"), (64, "32x32@2x"),
                     (128, "128x128"), (256, "128x128@2x"), (256, "256x256"),
                     (512, "256x256@2x"), (512, "512x512"), (1024, "512x512@2x")] {
    let img = draw(size: CGFloat(size))
    guard let tiff = img.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else { continue }
    try? png.write(to: URL(fileURLWithPath: "\(out)/icon_\(name).png"))
}
print("iconset → \(out)")
