//
//  Object.swift
//  ScreenNote
//
//  Created by Takuto Nakamura on 2020/05/04.
//  Copyright © 2020 Kyome. All rights reserved.
//

import Cocoa

enum ObjectType: Int {
    case select
    case pen
    case line
    case fillRect
    case lineRect
    case fillOval
    case lineOval
    case text
}

struct Object {
    
    let type: ObjectType
    var colorID: Int
    var alpha: CGFloat
    var lineWidth: CGFloat
    var points: [CGPoint]
    var isSelected: Bool
    var text: String = "" {
        didSet {
            setTextImage()
        }
    }
    var textImage: NSImage?
    
    var bounds: CGRect {
        let minX = points.min(by: { (a, b) -> Bool in return a.x < b.x })?.x ?? 0
        let minY = points.min(by: { (a, b) -> Bool in return a.y < b.y })?.y ?? 0
        let maxX = points.max(by: { (a, b) -> Bool in return a.x < b.x })?.x ?? 0
        let maxY = points.max(by: { (a, b) -> Bool in return a.y < b.y })?.y ?? 0
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    var path: NSBezierPath {
        let path = NSBezierPath()
        path.lineWidth = lineWidth
        switch type {
        case .select:
            path.appendRect(bounds)
            path.lineWidth = 3.0
            path.setLineDash([5.0, 5.0], count: 2, phase: 0.0)
        case .pen:
            if points.count < 2 {
                path.appendOval(in: NSRect(origin: points.first! - CGPoint(0.5 * lineWidth), size: CGSize(lineWidth)))
            } else {
                path.move(to: points.first!)
                for point in points.dropFirst() {
                    path.line(to: point)
                }
            }
        case .line:
            path.move(to: points[0])
            path.line(to: points[1])
        case .fillRect, .lineRect, .text:
            path.appendRect(bounds)
        case .fillOval, .lineOval:
            path.appendOval(in: bounds)
        }
        return path
    }

    var copy: Object {
        let newPoints = self.points.map { (p) -> CGPoint in
            return CGPoint(x: p.x + 20, y: p.y - 20)
        }
        var obj = Object(self.type, self.colorID, self.alpha, self.lineWidth, newPoints)
        obj.isSelected = true
        if self.type == .text {
            obj.text = self.text
        }
        return obj
    }
    
    init(_ type: ObjectType, _ colorID: Int, _ alpha: CGFloat, _ lineWidth: CGFloat, _ points: [CGPoint]) {
        self.type = type
        self.colorID = colorID
        self.alpha = alpha
        self.lineWidth = lineWidth
        self.points = points
        self.isSelected = false
        if self.type == .text {
            self.text = "Text"
            setTextImage()
        }
    }
    
    func isHit(_ point: CGPoint) -> Bool {
        switch type {
        case .pen, .line, .lineRect, .lineOval:
            return path.intersects(with: point, radius: max(4.0, 0.5 * lineWidth))
        case .fillRect, .fillOval, .text:
            return path.contains(point)
        default:
            return false
        }
    }
    
    func isHit(_ selectRect: CGRect) -> Bool {
        if selectRect.contains(bounds) {
            return true
        }
        return path.intersects(NSBezierPath(rect: selectRect))
    }

    private mutating func setTextImage() {
        let str = NSString(string: text)
        let attr: [NSAttributedString.Key : Any] = [.font : NSFont.systemFont(ofSize: 100.0)]
        let size = str.size(withAttributes: attr)
        let image = NSImage(size: size)
        image.lockFocus()
        str.draw(at: .zero, withAttributes: attr)
        image.unlockFocus()
        textImage = image

        // update size
        let newWidth = size.width / size.height * bounds.height
        if points[0].x <= points[1].x {
            points[1].x = points[0].x + newWidth
        } else {
            points[0].x = points[1].x + newWidth
        }
    }

}
