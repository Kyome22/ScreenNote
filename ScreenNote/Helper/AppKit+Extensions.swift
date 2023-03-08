/*
  AppKit+Extensions.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import AppKit

extension NSStatusItem {
    static var `default`: NSStatusItem {
        return NSStatusBar.system.statusItem(withLength: Self.variableLength)
    }
}

extension NSMenu {
    func addItem(title: String, action: Selector, target: AnyObject) {
        self.addItem(NSMenuItem(title: title, action: action, target: target))
    }

    func addSeparator() {
        self.addItem(NSMenuItem.separator())
    }
}

extension NSMenuItem {
    convenience init(title: String, action: Selector, target: AnyObject) {
        self.init(title: title, action: action, keyEquivalent: "")
        self.target = target
    }

    func setValues(title: String, action: Selector, target: AnyObject) {
        self.title = title
        self.action = action
        self.target = target
    }
}

extension NSTextField {
    open override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if flags == [.command] {
            let selector: Selector
            switch event.charactersIgnoringModifiers?.lowercased() {
            case "x": selector = #selector(NSText.cut(_:))
            case "c": selector = #selector(NSText.copy(_:))
            case "v": selector = #selector(NSText.paste(_:))
            case "a": selector = #selector(NSText.selectAll(_:))
            case "z": selector = Selector(("undo:"))
            default: return super.performKeyEquivalent(with: event)
            }
            return NSApp.sendAction(selector, to: nil, from: self)
        } else if flags == [.shift, .command] {
            if event.charactersIgnoringModifiers?.lowercased() == "z" {
                return NSApp.sendAction(Selector(("redo:")), to: nil, from: self)
            }
        }
        return super.performKeyEquivalent(with: event)
    }
}

extension NSTextView {
    open override var frame: NSRect {
        didSet {
            self.insertionPointColor = NSColor.controlAccentColor
        }
    }
}

extension String {
    func calculateSize(using font: NSFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font : font]
        return NSAttributedString(string: self, attributes: attributes).size()
    }
}

extension NSColor {
    static let primaries: [NSColor] = [
        NSColor(named: "UniqueWhite")!,
        NSColor(named: "UniqueRed")!,
        NSColor(named: "UniqueOrange")!,
        NSColor(named: "UniqueYello")!,
        NSColor(named: "UniqueGreen")!,
        NSColor(named: "UniqueBlue")!,
        NSColor(named: "UniqueViolet")!,
        NSColor(named: "UniquePurple")!
    ]
}
