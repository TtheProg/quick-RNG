import SwiftUI
import AppKit

/// SwiftUI's `TextField` can't select its own contents on demand, and its focus
/// is unreliable inside a non-activating panel — both of which this app depends
/// on. So the input is a plain `NSTextField` we drive directly.
struct RollField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var font: NSFont
    var accent: NSColor
    /// Increment to re-focus. Increment to select everything.
    var focusToken: Int
    var selectAllToken: Int

    var onSubmit: () -> Void
    var onEscape: () -> Void = {}
    var onUp: () -> Void = {}
    var onDown: () -> Void = {}

    func makeNSView(context: Context) -> NSTextField {
        let field = NSTextField()
        field.delegate = context.coordinator
        field.isBordered = false
        field.drawsBackground = false
        field.focusRingType = .none
        field.font = font
        field.lineBreakMode = .byTruncatingTail
        field.cell?.usesSingleLineMode = true
        field.cell?.wraps = false
        field.cell?.isScrollable = true
        field.stringValue = text
        // Return arrives here; `doCommandBy` below is the belt to this braces.
        field.target = context.coordinator
        field.action = #selector(Coordinator.submit(_:))
        return field
    }

    func updateNSView(_ field: NSTextField, context: Context) {
        context.coordinator.parent = self   // closures below must not go stale
        if field.stringValue != text { field.stringValue = text }
        field.font = font
        field.placeholderAttributedString = NSAttributedString(
            string: placeholder,
            attributes: [.font: font, .foregroundColor: Theme.placeholderNS]
        )
        field.textColor = Theme.inputNS
        if let editor = field.currentEditor() as? NSTextView {
            editor.insertionPointColor = accent
            editor.selectedTextAttributes = [
                .backgroundColor: accent.withAlphaComponent(0.30),
                .foregroundColor: Theme.inputNS
            ]
        }

        let c = context.coordinator
        if c.lastFocusToken != focusToken {
            c.lastFocusToken = focusToken
            DispatchQueue.main.async {
                field.window?.makeFirstResponder(field)
                field.currentEditor()?.selectAll(nil)
            }
        }
        if c.lastSelectAllToken != selectAllToken {
            c.lastSelectAllToken = selectAllToken
            DispatchQueue.main.async { field.currentEditor()?.selectAll(nil) }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: RollField
        var lastFocusToken = Int.min
        var lastSelectAllToken = Int.min

        init(_ parent: RollField) { self.parent = parent }

        @objc func submit(_ sender: NSTextField) {
            parent.text = sender.stringValue
            parent.onSubmit()
        }

        func controlTextDidChange(_ note: Notification) {
            guard let f = note.object as? NSTextField else { return }
            parent.text = f.stringValue
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy selector: Selector) -> Bool {
            switch selector {
            case #selector(NSResponder.insertNewline(_:)):
                parent.text = control.stringValue
                parent.onSubmit()
                return true
            case #selector(NSResponder.cancelOperation(_:)):
                parent.onEscape()
                return true
            case #selector(NSResponder.moveUp(_:)):
                parent.onUp()
                return true
            case #selector(NSResponder.moveDown(_:)):
                parent.onDown()
                return true
            default:
                return false
            }
        }
    }
}
