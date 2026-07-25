import AppKit

extension NSWindow {
    /// Sizes the window to `size`, but never larger than the screen it opens on.
    /// A window taller than the display can end up with its title bar — and with
    /// it the close button — off screen, which makes it unclosable.
    func setContentSizeClamped(_ size: NSSize, on screen: NSScreen? = nil) {
        let visible = (screen ?? self.screen ?? NSScreen.main)?.visibleFrame
            ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let chromeHeight = frame.height - contentRect(forFrameRect: frame).height
        setContentSize(NSSize(
            width: min(size.width, visible.width - 40),
            height: min(size.height, visible.height - chromeHeight - 40)
        ))
    }
}
