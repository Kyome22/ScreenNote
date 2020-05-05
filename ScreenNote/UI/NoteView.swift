//
//  NoteView.swift
//  ScreenNote
//
//  Created by Takuto Nakamura on 2019/06/08.
//  Copyright © 2019 Kyome. All rights reserved.
//

import Cocoa

class NoteView: NSView {
    
    let om = ObjectManager.shared
    
    init() {
        super.init(frame: .zero)
        self.wantsLayer = true
        self.layer?.backgroundColor = CGColor.clear
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        for object in om.objects {
            om.colors[object.colorID].withAlphaComponent(object.alpha).set()
            let path = object.path
            switch object.type {
            case .pen, .line:
                if object.type == .pen && object.points.count < 2 {
                    path.fill()
                    break
                }
                path.lineJoinStyle = .round
                path.lineCapStyle = .round
                path.stroke()
            case .fillRect, .fillOval:
                path.fill()
            case .lineRect, .lineOval:
                path.stroke()
            default:
                break
            }
        }
        NSColor.select(0.8).set()
        if let bounds = om.selectedBounds(om.selectedObjects) {
            let rect = NSBezierPath(rect: bounds)
            rect.lineWidth = 1.5
            rect.stroke()
            NSBezierPath.anchorPaths(bounds: bounds).forEach { (path) in
                path.fill()
            }
            
        }
        om.selectObject?.path.stroke()
    }
    
}
