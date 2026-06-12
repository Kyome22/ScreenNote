import CoreGraphics

extension CGPoint {
    public init(_ scalar: CGFloat) {
        self.init(x: scalar, y: scalar)
    }

    public func length(from: CGPoint) -> CGFloat {
        sqrt(pow(x - from.x, 2.0) + pow(y - from.y, 2.0))
    }

    public func radian(from: CGPoint) -> CGFloat {
        atan2(y - from.y, x - from.x)
    }

    public func distance(_ line: Line) -> CGFloat {
        let lengthX = line.p0.x - line.p1.x
        let lengthY = line.p0.y - line.p1.y
        let startX = line.p0.x - x
        let startY = line.p0.y - y
        let startDot = lengthX * startX + lengthY * startY
        guard 0 < startDot else {
            return (startX * startX + startY * startY).squareRoot()
        }
        let endX = x - line.p1.x
        let endY = y - line.p1.y
        let endDot = lengthX * endX + lengthY * endY
        guard 0 < endDot else {
            return (endX * endX + endY * endY).squareRoot()
        }
        return abs(lengthX * startY - lengthY * startX) / (startDot + endDot).squareRoot()
    }
}

extension CGSize {
    public init(_ side: CGFloat) {
        self.init(width: side, height: side)
    }
}

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    CGPoint(x: left.x - right.x, y: left.y - right.y)
}

public func -= (left: inout CGPoint, right: CGPoint) {
    left = left - right
}

public func * (left: CGFloat, right: CGPoint) -> CGPoint {
    CGPoint(x: left * right.x, y: left * right.y)
}

public func + (left: CGSize, right: CGSize) -> CGSize {
    CGSize(width: left.width + right.width, height: left.height + right.height)
}

public func += (left: inout CGSize, right: CGSize) {
    left = left + right
}

public func - (left: CGSize, right: CGSize) -> CGSize {
    CGSize(width: left.width - right.width, height: left.height - right.height)
}

public func -= (left: inout CGSize, right: CGSize) {
    left = left - right
}

public func * (left: CGFloat, right: CGSize) -> CGSize {
    CGSize(width: left * right.width, height: left * right.height)
}
