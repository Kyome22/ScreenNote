import CoreGraphics

public struct Curve: Sendable {
    let p1: CGPoint
    let c1: CGPoint
    let c2: CGPoint
    let p2: CGPoint

    public init(_ p1: CGPoint, _ c1: CGPoint, _ c2: CGPoint, _ p2: CGPoint) {
        self.p1 = p1
        self.c1 = c1
        self.c2 = c2
        self.p2 = p2
    }

    func compute(_ t: CGFloat) -> CGPoint {
        var point = pow(1.0 - t, 3.0) * p1
        point += (3.0 * pow(1.0 - t, 2.0) * t) * c1
        point += (3.0 * (1.0 - t) * pow(t, 2.0)) * c2
        point += pow(t, 3.0) * p2
        return point
    }

    public var points: [CGPoint] {
        (0 ..< 10).map { compute(CGFloat($0 + 1) / 10.0) }
    }
}
