import CoreGraphics

public enum Anchor: Int, CaseIterable, Sendable, Equatable {
    case topLeft
    case top
    case topRight
    case left
    case right
    case bottomLeft
    case bottom
    case bottomRight

    public func center(with bounds: CGRect) -> CGPoint {
        switch self {
        case .topLeft:
            CGPoint(x: bounds.minX, y: bounds.minY)
        case .top:
            CGPoint(x: bounds.midX, y: bounds.minY)
        case .topRight:
            CGPoint(x: bounds.maxX, y: bounds.minY)
        case .left:
            CGPoint(x: bounds.minX, y: bounds.midY)
        case .right:
            CGPoint(x: bounds.maxX, y: bounds.midY)
        case .bottomLeft:
            CGPoint(x: bounds.minX, y: bounds.maxY)
        case .bottom:
            CGPoint(x: bounds.midX, y: bounds.maxY)
        case .bottomRight:
            CGPoint(x: bounds.maxX, y: bounds.maxY)
        }
    }

    public static func rects(bounds: CGRect) -> [CGRect] {
        let offset = CGPoint(4.0)
        let size = CGSize(8.0)
        guard !bounds.isEmpty else {
            return [CGRect(origin: bounds.origin - offset, size: size)]
        }
        return allCases.map { anchor in
            CGRect(origin: anchor.center(with: bounds) - offset, size: size)
        }
    }

    public static func hitAnchor(of point: CGPoint, in bounds: CGRect) -> Anchor? {
        zip(rects(bounds: bounds), allCases)
            .first { $0.0.contains(point) }?.1
    }

    public func resize(bounds: CGRect, with diff: CGPoint) -> CGRect {
        // CGRect.size.width differs from CGRect.width: the latter is normalized to be positive.
        let size = CGSize(width: bounds.width, height: bounds.height)
        var resizedBounds = CGRect(origin: bounds.origin, size: size)
        switch self {
        case .topLeft:
            resizedBounds.origin.x += diff.x
            resizedBounds.origin.y += diff.y
            resizedBounds.size.width -= diff.x
            resizedBounds.size.height -= diff.y
        case .top:
            resizedBounds.origin.y += diff.y
            resizedBounds.size.height -= diff.y
        case .topRight:
            resizedBounds.origin.y += diff.y
            resizedBounds.size.width += diff.x
            resizedBounds.size.height -= diff.y
        case .left:
            resizedBounds.origin.x += diff.x
            resizedBounds.size.width -= diff.x
        case .right:
            resizedBounds.size.width += diff.x
        case .bottomLeft:
            resizedBounds.origin.x += diff.x
            resizedBounds.size.width -= diff.x
            resizedBounds.size.height += diff.y
        case .bottom:
            resizedBounds.size.height += diff.y
        case .bottomRight:
            resizedBounds.size.width += diff.x
            resizedBounds.size.height += diff.y
        }
        return resizedBounds
    }
}
