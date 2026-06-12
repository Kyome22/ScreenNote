import AppKit

extension NSTextView {
    open override var frame: NSRect {
        didSet {
            insertionPointColor = NSColor.controlAccentColor
        }
    }
}
