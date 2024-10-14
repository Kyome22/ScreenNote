/*
  Object.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SwiftUI

struct Object: Identifiable {
    let id: String = UUID().uuidString
    let type: ObjectType
    var color_: Color
    var opacity: CGFloat
    var lineWidth: CGFloat
    var points: [CGPoint]
    var text: String
    var textOrientation: TextOrientation
    var isSelected: Bool
    var isHidden: Bool

    var bounds: CGRect {
        let minX = points.min(by: { $0.x < $1.x })?.x ?? 0
        let minY = points.min(by: { $0.y < $1.y })?.y ?? 0
        let maxX = points.max(by: { $0.x < $1.x })?.x ?? 0
        let maxY = points.max(by: { $0.y < $1.y })?.y ?? 0
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    var path: Path {
        switch type {
        case .select:
            return Path(bounds)
        case .text:
            return Path(bounds)
        case .pen:
            if points.isEmpty {
                fatalError("points is empty")
            }
            if points.count < 2 {
                let rect = CGRect(origin: points[0] - CGPoint(0.5 * lineWidth),
                                  size: CGSize(lineWidth))
                return Path(ellipseIn: rect)
            } else {
                var path = Path()
                path.addLines(points)
                return path
            }
        case .line:
            var path = Path()
            path.move(to: points[0])
            path.addLine(to: points[1])
            return path
        case .arrow:
            var path = Path()
            let p0 = points[0]
            let p1 = points[1]
            if p0 == p1 { return path }
            let length = 3.0 * lineWidth
            let d = 2.0 * lineWidth
            let phi = p0.radian(from: p1)
            let p2 = p1 + length * CGPoint(x: cos(phi), y: sin(phi))
            let r = 0.5 * lineWidth
            let phi_po_90 = phi + CGFloat.pi / 2.0
            let phi_ne_90 = phi - CGFloat.pi / 2.0
            let cos_po = cos(phi_po_90)
            let sin_po = sin(phi_po_90)
            let cos_ne = cos(phi_ne_90)
            let sin_ne = sin(phi_ne_90)
            if p0.length(from: p1) < length {
                path.move(to: p2 + d * CGPoint(x: cos_ne, y: sin_ne))
                path.addLine(to: p1 + r * CGPoint(x: -cos(phi), y: -sin(phi)))
                path.addLine(to: p2 + d * CGPoint(x: cos_po, y: sin_po))
                path.closeSubpath()
            } else {
                path.move(to: p0 + r * CGPoint(x: cos_ne, y: sin_ne))
                path.addLine(to: p2 + r * CGPoint(x: -cos_po, y: -sin_po))
                path.addLine(to: p2 + d * CGPoint(x: -cos_po, y: -sin_po))
                path.addLine(to: p1 + r * CGPoint(x: -cos(phi), y: -sin(phi)))
                path.addLine(to: p2 + d * CGPoint(x: -cos_ne, y: -sin_ne))
                path.addLine(to: p2 + r * CGPoint(x: -cos_ne, y: -sin_ne))
                path.addLine(to: p0 + r * CGPoint(x: cos_po, y: sin_po))
                path.addArc(center: p0,
                            radius: r,
                            startAngle: Angle(radians: phi_po_90),
                            endAngle: Angle(radians: phi_ne_90),
                            clockwise: true)
                path.closeSubpath()
            }
            return path
        case .fillRect, .lineRect:
            return Path(bounds)
        case .fillOval, .lineOval:
            return Path(ellipseIn: bounds)
        }
    }

    var strokeStyle: StrokeStyle? {
        switch type {
        case .select, .text, .arrow, .fillRect, .fillOval:
            nil
        case .pen where points.count < 2:
            nil
        case .pen:
            StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
        case .line:
            StrokeStyle(lineWidth: lineWidth, lineCap: .round)
        case .lineRect, .lineOval:
            StrokeStyle(lineWidth: lineWidth)
        }
    }

    var color: Color {
        color_.opacity(opacity)
    }

    var fontSize: CGFloat {
        let numberOfLines = text.components(separatedBy: .newlines).count
        let height = textOrientation.size(of: bounds).height
        let heightOfLine = height / CGFloat(numberOfLines)
        var estimatedFontSize = (2.0 * (heightOfLine - 0.2078) / 1.176).rounded() / 2.0
        var estimatedSize = text.calculateSize(using: NSFont.systemFont(ofSize: estimatedFontSize))
        while height < estimatedSize.height {
            estimatedFontSize -= 0.1
            estimatedSize = text.calculateSize(using: NSFont.systemFont(ofSize: estimatedFontSize))
        }
        return estimatedFontSize
    }

    init (
        _ type: ObjectType,
        _ color: Color,
        _ opacity: CGFloat,
        _ lineWidth: CGFloat,
        _ points: [CGPoint],
        isSelected: Bool = false
    ) {
        self.type = type
        self.color_ = color
        self.opacity = opacity
        self.lineWidth = lineWidth
        self.points = points
        self.text = ""
        self.textOrientation = .up
        self.isSelected = isSelected
        self.isHidden = false
    }

    init (
        _ color: Color,
        _ opacity: CGFloat,
        _ points: [CGPoint],
        _ text: String,
        _ textOrientation: TextOrientation,
        isSelected: Bool = false
    ) {
        self.type = .text
        self.color_ = color
        self.opacity = opacity
        self.lineWidth = 1.0
        self.points = points
        self.text = text
        self.textOrientation = textOrientation
        self.isSelected = isSelected
        self.isHidden = false
    }

    func isHit(point: CGPoint) -> Bool {
        switch type {
        case .pen, .line, .lineRect, .lineOval:
            path.intersects(with: point, radius: max(4.0, 0.5 * lineWidth))
        case .text, .arrow, .fillRect, .fillOval:
            path.contains(point)
        default:
            false
        }
    }

    func isHit(rect: CGRect) -> Bool {
        if rect.isEmpty {
            false
        } else if rect.contains(bounds) {
            true
        } else {
            path.intersects(Path(rect))
        }
    }

    func copy(needsOffset: Bool = false) -> Object {
        let newPoints = needsOffset ? points.map { $0 + CGPoint(20) } : points
        return if type == .text {
            Object(color_, opacity, newPoints, text, textOrientation, isSelected: true)
        } else {
            Object(type, color_, opacity, lineWidth, newPoints, isSelected: true)
        }
    }

    func textOffset(from bounds: CGRect) -> CGPoint {
        CGPoint(x: bounds.midX, y: bounds.midY)
    }

    func textRect(from bounds: CGRect) -> CGRect {
        let size = textOrientation.size(of: bounds)
        return CGRect(
            x: -0.5 * size.width,
            y: -0.5 * size.height,
            width: size.width,
            height: size.height
        )
    }
}
