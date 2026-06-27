import CoreGraphics

public enum TextOrientation: Int, CaseIterable, Sendable, Equatable {
    case up
    case right
    case down
    case left
    case upMirrored
    case rightMirrored
    case downMirrored
    case leftMirrored

    public func size(of bounds: CGRect) -> CGSize {
        switch self {
        case .up, .down, .upMirrored, .downMirrored:
            CGSize(width: bounds.width, height: bounds.height)
        case .right, .left, .rightMirrored, .leftMirrored:
            CGSize(width: bounds.height, height: bounds.width)
        }
    }

    private func rotateRight() -> Self {
        switch self {
        case .up:
            TextOrientation.right
        case .right:
            TextOrientation.down
        case .down:
            TextOrientation.left
        case .left:
            TextOrientation.up
        case .upMirrored:
            TextOrientation.leftMirrored
        case .rightMirrored:
            TextOrientation.upMirrored
        case .downMirrored:
            TextOrientation.rightMirrored
        case .leftMirrored:
            TextOrientation.downMirrored
        }
    }

    private func rotateLeft() -> Self {
        switch self {
        case .up:
            TextOrientation.left
        case .right:
            TextOrientation.up
        case .down:
            TextOrientation.right
        case .left:
            TextOrientation.down
        case .upMirrored:
            TextOrientation.rightMirrored
        case .rightMirrored:
            TextOrientation.downMirrored
        case .downMirrored:
            TextOrientation.leftMirrored
        case .leftMirrored:
            TextOrientation.upMirrored
        }
    }

    public func rotate(_ rotateMethod: RotateMethod) -> Self {
        switch rotateMethod {
        case .rotateRight:
            rotateRight()
        case .rotateLeft:
            rotateLeft()
        }
    }

    private func flipHorizontal() -> Self {
        switch self {
        case .up:
            TextOrientation.upMirrored
        case .right:
            TextOrientation.rightMirrored
        case .down:
            TextOrientation.downMirrored
        case .left:
            TextOrientation.leftMirrored
        case .upMirrored:
            TextOrientation.up
        case .rightMirrored:
            TextOrientation.right
        case .downMirrored:
            TextOrientation.down
        case .leftMirrored:
            TextOrientation.left
        }
    }

    private func flipVertical() -> Self {
        switch self {
        case .up:
            TextOrientation.downMirrored
        case .right:
            TextOrientation.leftMirrored
        case .down:
            TextOrientation.upMirrored
        case .left:
            TextOrientation.rightMirrored
        case .upMirrored:
            TextOrientation.down
        case .rightMirrored:
            TextOrientation.left
        case .downMirrored:
            TextOrientation.up
        case .leftMirrored:
            TextOrientation.right
        }
    }

    public func flip(_ flipMethod: FlipMethod) -> Self {
        switch flipMethod {
        case .flipHorizontal:
            flipHorizontal()
        case .flipVertical:
            flipVertical()
        }
    }

    public func endPosition(with position: CGPoint, size: CGSize) -> CGPoint {
        switch self {
        case .up:
            CGPoint(x: position.x + size.width, y: position.y + size.height)
        case .right:
            CGPoint(x: position.x - size.height, y: position.y + size.width)
        case .down:
            CGPoint(x: position.x - size.width, y: position.y - size.height)
        case .left:
            CGPoint(x: position.x + size.height, y: position.y - size.width)
        case .upMirrored:
            CGPoint(x: position.x - size.width, y: position.y + size.height)
        case .rightMirrored:
            CGPoint(x: position.x + size.height, y: position.y + size.width)
        case .downMirrored:
            CGPoint(x: position.x + size.width, y: position.y - size.height)
        case .leftMirrored:
            CGPoint(x: position.x - size.height, y: position.y - size.width)
        }
    }
}
