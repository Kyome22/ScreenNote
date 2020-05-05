//
//  LookMePanel.swift
//  ScreenNote
//
//  Created by Takuto Nakamura on 2020/05/06.
//  Copyright © 2020 Kyome. All rights reserved.
//

import Cocoa

class LookMePanel: NSPanel {

    private let innerView: LookMeView!
    private let iconView: NSImageView!
    private let label: NSTextField!
    
    init(frame: NSRect) {
        let bounds = NSRect(origin: .zero, size: frame.size)
        innerView = LookMeView(frame: bounds)
        iconView = NSImageView(image: NSImage(named: "Icon")!)
        label = NSTextField(labelWithString: "here".localized)
        super.init(contentRect: frame,
                   styleMask: [.borderless, .nonactivatingPanel],
                   backing: .buffered,
                   defer: true)
        self.level = .modalPanel
        self.collectionBehavior = [.canJoinAllSpaces]
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        self.contentView = innerView
        innerView.addSubview(iconView)
        iconView.frame = NSRect(x: bounds.midX - 64.0, y: 60.0, width: 128, height: 128)
        
        let shadow = NSShadow()
        shadow.shadowOffset = NSMakeSize(2, -2)
        shadow.shadowColor = NSColor.black
        shadow.shadowBlurRadius = 3
        iconView.shadow = shadow
        
        innerView.addSubview(label)
        label.font = NSFont.systemFont(ofSize: 30.0)
        label.sizeToFit()
        label.setFrameOrigin(NSPoint(x: bounds.midX - label.bounds.midX, y: 15.0))
    }
    
    func fadeOut() {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            self.animator().alphaValue = 0.0
        }) {
            self.close()
        }
    }
    
}

fileprivate class LookMeView: NSView {
    
    var w: CGFloat { return self.frame.width }
    var h: CGFloat { return self.frame.height }
    var r: CGFloat = 14
    var a: CGFloat = 16
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let path = NSBezierPath()
        path.move(to: NSPoint(x: 0.5 * w - a, y: h - a))
        path.line(to: NSPoint(x: 0.5 * w, y: h))
        path.line(to: NSPoint(x: 0.5 * w + a, y: h - a))
        path.line(to: NSPoint(x: w - r, y: h - a))
        path.curve(to: NSPoint(x: w, y: h - a - r),
                   controlPoint1: NSPoint(x: w, y: h - a),
                   controlPoint2: NSPoint(x: w, y: h - a))
        path.line(to: NSPoint(x: w, y: r))
        path.curve(to: NSPoint(x: w - r, y: 0),
                   controlPoint1: NSPoint(x: w, y: 0),
                   controlPoint2: NSPoint(x: w, y: 0))
        path.line(to: NSPoint(x: 8, y: 0))
        path.curve(to: NSPoint(x: 0, y: r),
                   controlPoint1: NSPoint.zero,
                   controlPoint2: NSPoint.zero)
        path.line(to: NSPoint(x: 0, y: h - a - r))
        path.curve(to: NSPoint(x: 8, y: h - a),
                   controlPoint1: NSPoint(x: 0, y: h - a),
                   controlPoint2: NSPoint(x: 0, y: h - a))
        path.close()
        NSColor.tutorialBG.setFill()
        path.fill()
    }
    
}
