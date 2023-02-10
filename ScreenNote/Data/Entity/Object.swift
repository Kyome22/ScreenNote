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
        case .fillRect, .lineRect:
            return Path(bounds)
        case .fillOval, .lineOval:
            return Path(ellipseIn: bounds)
        }
    }

    var strokeStyle: StrokeStyle? {
        switch type {
        case .select, .text, .fillRect, .fillOval:
            return nil
        case .pen:
            if points.count < 2 {
                return nil
            }
            return StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
        case .line:
            return StrokeStyle(lineWidth: lineWidth, lineCap: .round)
        case .lineRect, .lineOval:
            return StrokeStyle(lineWidth: lineWidth)
        }
    }

    var color: Color {
        return color_.opacity(opacity)
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
            let radius: CGFloat = max(4.0, 0.5 * lineWidth)
            return path.intersects(with: point, radius: radius)
        case .text, .fillRect, .fillOval:
            return path.contains(point)
        default:
            return false
        }
    }

    func isHit(rect: CGRect) -> Bool {
        if rect.isEmpty { return false }
        if rect.contains(bounds) { return true }
        return path.intersects(Path(rect))
    }

    func copy(needsOffset: Bool = false) -> Object {
        let newPoints = needsOffset ? points.map { $0 + CGPoint(20) } : points
        if type == .text {
            return Object(color_, opacity, newPoints, text, textOrientation, isSelected: true)
        } else {
            return Object(type, color_, opacity, lineWidth, newPoints, isSelected: true)
        }
    }

    func textOffset(from bounds: CGRect) -> CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }

    func textRect(from bounds: CGRect) -> CGRect {
        let size = textOrientation.size(of: bounds)
        return CGRect(x: -0.5 * size.width,
                      y: -0.5 * size.height,
                      width: size.width,
                      height: size.height)
    }

    func inputTextOffset(from bounds: CGRect) -> CGSize {
        return CGSize(width: bounds.minX, height: bounds.minY)
    }
}
