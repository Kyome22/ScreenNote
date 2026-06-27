import AppKit

public struct Object: Identifiable, Sendable, Equatable {
    public let id: String
    public let type: ObjectType
    public var paletteIndex: Int
    public var opacity: CGFloat
    public var lineWidth: CGFloat
    public var points: [CGPoint]
    public var text: String
    public var textOrientation: TextOrientation
    public var isSelected: Bool
    public var isHidden: Bool

    public init(
        _ type: ObjectType,
        _ paletteIndex: Int,
        _ opacity: CGFloat,
        _ lineWidth: CGFloat,
        _ points: [CGPoint],
        isSelected: Bool = false
    ) {
        self.id = UUID().uuidString
        self.type = type
        self.paletteIndex = paletteIndex
        self.opacity = opacity
        self.lineWidth = lineWidth
        self.points = points
        self.text = ""
        self.textOrientation = .up
        self.isSelected = isSelected
        self.isHidden = false
    }

    public init(
        _ paletteIndex: Int,
        _ opacity: CGFloat,
        _ points: [CGPoint],
        _ text: String,
        _ textOrientation: TextOrientation,
        isSelected: Bool = false
    ) {
        self.id = UUID().uuidString
        self.type = .text
        self.paletteIndex = paletteIndex
        self.opacity = opacity
        self.lineWidth = 1.0
        self.points = points
        self.text = text
        self.textOrientation = textOrientation
        self.isSelected = isSelected
        self.isHidden = false
    }

    public var bounds: CGRect {
        let minX = points.min(by: { $0.x < $1.x })?.x ?? 0
        let minY = points.min(by: { $0.y < $1.y })?.y ?? 0
        let maxX = points.max(by: { $0.x < $1.x })?.x ?? 0
        let maxY = points.max(by: { $0.y < $1.y })?.y ?? 0
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    public var cgPath: CGPath {
        makeCGPath()
    }

    public var fontSize: CGFloat {
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

    public func isHit(point: CGPoint) -> Bool {
        switch type {
        case .pen, .line, .lineRect, .lineOval:
            cgPath.intersects(with: point, radius: max(4.0, 0.5 * lineWidth))
        case .text, .arrow, .fillRect, .fillOval:
            cgPath.contains(point)
        default:
            false
        }
    }

    public func isHit(rect: CGRect) -> Bool {
        if rect.isEmpty {
            false
        } else if rect.contains(bounds) {
            true
        } else {
            cgPath.intersects(CGPath(rect: rect, transform: nil))
        }
    }

    public func copy(needsOffset: Bool = false) -> Object {
        let newPoints = needsOffset ? points.map { $0 + CGPoint(20) } : points
        return if type == .text {
            Object(paletteIndex, opacity, newPoints, text, textOrientation, isSelected: true)
        } else {
            Object(type, paletteIndex, opacity, lineWidth, newPoints, isSelected: true)
        }
    }

    public func textOffset(from bounds: CGRect) -> CGPoint {
        CGPoint(x: bounds.midX, y: bounds.midY)
    }

    public func textRect(from bounds: CGRect) -> CGRect {
        let size = textOrientation.size(of: bounds)
        return CGRect(
            x: -0.5 * size.width,
            y: -0.5 * size.height,
            width: size.width,
            height: size.height
        )
    }

    private func makeCGPath() -> CGPath {
        switch type {
        case .select, .text, .fillRect, .lineRect:
            CGPath(rect: bounds, transform: nil)
        case .pen:
            makePenPath()
        case .line:
            makeLinePath()
        case .arrow:
            makeArrowPath()
        case .fillOval, .lineOval:
            CGPath(ellipseIn: bounds, transform: nil)
        }
    }

    private func makePenPath() -> CGPath {
        let path = CGMutablePath()
        guard let firstPoint = points.first else { return path }
        if points.count < 2 {
            let rect = CGRect(origin: firstPoint - CGPoint(0.5 * lineWidth), size: CGSize(lineWidth))
            return CGPath(ellipseIn: rect, transform: nil)
        }
        path.addLines(between: points)
        return path
    }

    private func makeLinePath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: points[0])
        path.addLine(to: points[1])
        return path
    }

    private func makeArrowPath() -> CGPath {
        let path = CGMutablePath()
        let p0 = points[0]
        let p1 = points[1]
        if p0 == p1 { return path }
        let length = 3.0 * lineWidth
        let d = 2.0 * lineWidth
        let phi = p0.radian(from: p1)
        let p2 = p1 + length * CGPoint(x: cos(phi), y: sin(phi))
        let r = 0.5 * lineWidth
        let phiPositive90 = phi + CGFloat.pi / 2.0
        let phiNegative90 = phi - CGFloat.pi / 2.0
        let cosPositive = cos(phiPositive90)
        let sinPositive = sin(phiPositive90)
        let cosNegative = cos(phiNegative90)
        let sinNegative = sin(phiNegative90)
        if p0.length(from: p1) < length {
            path.move(to: p2 + d * CGPoint(x: cosNegative, y: sinNegative))
            path.addLine(to: p1 + r * CGPoint(x: -cos(phi), y: -sin(phi)))
            path.addLine(to: p2 + d * CGPoint(x: cosPositive, y: sinPositive))
            path.closeSubpath()
        } else {
            path.move(to: p0 + r * CGPoint(x: cosNegative, y: sinNegative))
            path.addLine(to: p2 + r * CGPoint(x: -cosPositive, y: -sinPositive))
            path.addLine(to: p2 + d * CGPoint(x: -cosPositive, y: -sinPositive))
            path.addLine(to: p1 + r * CGPoint(x: -cos(phi), y: -sin(phi)))
            path.addLine(to: p2 + d * CGPoint(x: -cosNegative, y: -sinNegative))
            path.addLine(to: p2 + r * CGPoint(x: -cosNegative, y: -sinNegative))
            path.addLine(to: p0 + r * CGPoint(x: cosPositive, y: sinPositive))
            path.addArc(
                center: p0,
                radius: r,
                startAngle: phiPositive90,
                endAngle: phiNegative90,
                clockwise: true
            )
            path.closeSubpath()
        }
        return path
    }
}
