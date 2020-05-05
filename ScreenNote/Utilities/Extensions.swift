//
//  NSColorCode.swift
//  TweetStream
//
//  Created by Takuto Nakamura on 2017/03/15.
//  Copyright © 2017年 Kyome. All rights reserved.
//

import AppKit
import CoreGraphics

func logput(_ item: Any, file: String = #file, line: Int = #line, function: String = #function) {
    #if DEBUG
    Swift.print("Log: \(file):Line\(line):\(function)", item)
    #endif
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}

extension NSAppearance {
    var isDark: Bool {
        if self.name == .vibrantDark { return true }
        guard #available(macOS 10.14, *) else { return false }
        return self.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
    }
}

extension NSMenuItem {
    func setAction(target: AnyObject, selector: Selector) {
        self.target = target
        self.action = selector
    }
}

extension CGColor {
    static let tutorialBG = NSColor(named: "tutorialBG")!.cgColor
    
    static let darkButton = NSColor(named: "darkButton")!.cgColor
    static let lightButton = NSColor(named: "lightButton")!.cgColor
    static let darkToolBG = NSColor(named: "darkToolBG")!.cgColor
    static let lightToolBG = NSColor(named: "lightToolBG")!.cgColor
}

extension NSColor {
    static let tutorialBG = NSColor(named: "tutorialBG")!
    static let tutorialText = NSColor(named: "tutorialText")!
    
    static let uniqueRed = NSColor(named: "uniqueRed")!
    static let uniqueOrange = NSColor(named: "uniqueOrange")!
    static let uniqueYello = NSColor(named: "uniqueYello")!
    static let uniqueGreen = NSColor(named: "uniqueGreen")!
    static let uniqueBlue = NSColor(named: "uniqueBlue")!
    static let uniqueViolet = NSColor(named: "uniqueViolet")!
    static let uniquePurple = NSColor(named: "uniquePurple")!

    static func select(_ alpha: CGFloat) -> NSColor {
        return NSColor(named: "select")!.withAlphaComponent(alpha)
    }

    var swatch: NSImage {
        let image = NSImage(size: CGSize(19))
        image.lockFocus()
        let rect = NSRect(origin: CGPoint.zero, size: CGSize(19))
        let path = NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4)
        self.setFill()
        path.fill()
        image.unlockFocus()
        return image
    }
}

func + (l: CGPoint, r: CGPoint) -> CGPoint {
    return CGPoint(x: l.x + r.x, y: l.y + r.y)
}

func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

func - (l: CGPoint, r: CGPoint) -> CGPoint {
    return CGPoint(x: l.x - r.x, y: l.y - r.y)
}

func -= (left: inout CGPoint, right: CGPoint) {
    left = left - right
}


func + (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}

func += (left: inout CGSize, right: CGSize) {
    left = left + right
}

func - (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}

func -= (left: inout CGSize, right: CGSize) {
    left = left - right
}

func * (left: CGFloat, right: CGPoint) -> CGPoint {
    return CGPoint(x: left * right.x, y: left * right.y)
}

extension CGPoint {
    init(_ scalar: CGFloat) {
        self.init(x: scalar, y: scalar)
    }
    
    func length(from: CGPoint) -> CGFloat {
        return sqrt(pow(self.x - from.x, 2.0) + pow(self.y - from.y, 2.0))
    }
    
    func radian(from: CGPoint) -> CGFloat {
        return atan2(self.y - from.y, self.x - from.x)
    }
    
    func distance(_ line: Line) -> CGFloat {
        let lenX = line.p0.x - line.p1.x
        let lenY = line.p0.y - line.p1.y
        let sx = line.p0.x - self.x
        let sy = line.p0.y - self.y
        let s1 = lenX * sx + lenY * sy
        if s1 <= 0 {
            return (sx * sx + sy * sy).squareRoot()
        }
        let ex = self.x - line.p1.x
        let ey = self.y - line.p1.y
        let s2 = lenX * ex + lenY * ey
        if s2 <= 0 {
            return (ex * ex + ey * ey).squareRoot()
        }
        return abs(lenX * sy - lenY * sx) / (s1 + s2).squareRoot()
    }
    
}

extension CGSize {
    init(_ side: CGFloat) {
        self.init(width: side, height: side)
    }
}

extension NSBezierPath {
    
    var allPoints: [CGPoint] {
        var points = [CGPoint]()
        var elements = [CGPoint](repeating: CGPoint.zero, count: 3)
        for i in (0 ..< self.elementCount) {
            switch self.element(at: i, associatedPoints: &elements) {
            case .moveTo:
                points.append(elements[0])
            case .lineTo:
                points.append(elements[0])
            case .curveTo:
                guard let point = points.last else { continue }
                let curve = Curve([point] + elements)
                points.append(contentsOf: curve.points)
            case.closePath:
                continue
            @unknown default:
                fatalError()
            }
        }
        return points
    }
    
    static func anchorPaths(bounds b: CGRect) -> [NSBezierPath] {
        let u: CGFloat = 4.0
        let u2: CGFloat = 2.0 * u
        var paths = [NSBezierPath]()
        paths.append(NSBezierPath(rect: NSRect(origin: CGPoint(x: b.minX, y: b.maxY) - CGPoint(u), size: CGSize(u2))))
        paths.append(NSBezierPath(rect: NSRect(origin: CGPoint(x: b.midX, y: b.maxY) - CGPoint(u), size: CGSize(u2))))
        paths.append(NSBezierPath(rect: NSRect(origin: CGPoint(x: b.maxX, y: b.maxY) - CGPoint(u), size: CGSize(u2))))
        paths.append(NSBezierPath(rect: NSRect(origin: CGPoint(x: b.maxX, y: b.midY) - CGPoint(u), size: CGSize(u2))))
        paths.append(NSBezierPath(rect: NSRect(origin: CGPoint(x: b.maxX, y: b.minY) - CGPoint(u), size: CGSize(u2))))
        paths.append(NSBezierPath(rect: NSRect(origin: CGPoint(x: b.midX, y: b.minY) - CGPoint(u), size: CGSize(u2))))
        paths.append(NSBezierPath(rect: NSRect(origin: CGPoint(x: b.minX, y: b.minY) - CGPoint(u), size: CGSize(u2))))
        paths.append(NSBezierPath(rect: NSRect(origin: CGPoint(x: b.minX, y: b.midY) - CGPoint(u), size: CGSize(u2))))
        return paths
    }
    
    func intersects(with point: CGPoint, radius: CGFloat) -> Bool {
        let points = allPoints
        for i in (0 ..< points.count - 1) {
            let d = point.distance(Line(p0: points[i], p1: points[i + 1]))
            if d < radius {
                return true
            }
        }
        return false
    }
    
    func intersects(_ path: NSBezierPath) -> Bool {
        let pointsA = allPoints
        let pointsB = path.allPoints
        for i in (0 ..< pointsA.count - 1) {
            let lineA = Line(p0: pointsA[i], p1: pointsA[i + 1])
            for j in (0 ..< pointsB.count - 1) {
                let lineB = Line(p0: pointsB[j], p1: pointsB[j + 1])
                if lineA.intersects(lineB) {
                    return true
                }
            }
        }
        return false
    }
    
}
