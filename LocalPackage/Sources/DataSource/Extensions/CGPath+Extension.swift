import CoreGraphics

extension CGPath: @retroactive @unchecked Sendable {}

extension CGPath {
    public var allPoints: [CGPoint] {
        var points = [CGPoint]()
        applyWithBlock { element in
            switch element.pointee.type {
            case .moveToPoint:
                points.append(element.pointee.points[0])
            case .addLineToPoint:
                points.append(element.pointee.points[0])
            case .addCurveToPoint:
                guard let point = points.last else { break }
                let curve = Curve(
                    point,
                    element.pointee.points[0],
                    element.pointee.points[1],
                    element.pointee.points[2]
                )
                points.append(contentsOf: curve.points)
            case .addQuadCurveToPoint:
                guard let point = points.last else { break }
                let curve = Curve(
                    point,
                    element.pointee.points[0],
                    element.pointee.points[0],
                    element.pointee.points[1]
                )
                points.append(contentsOf: curve.points)
            case .closeSubpath:
                guard let point = points.first else { break }
                points.append(point)
            @unknown default:
                break
            }
        }
        return points
    }

    public func intersects(with point: CGPoint, radius: CGFloat) -> Bool {
        let points = allPoints
        guard 2 <= points.count else { return false }
        for index in 0 ..< points.count - 1 {
            if point.distance(Line(p0: points[index], p1: points[index + 1])) < radius {
                return true
            }
        }
        return false
    }

    public func intersects(_ path: CGPath) -> Bool {
        let pointsA = allPoints
        let pointsB = path.allPoints
        guard 2 <= pointsA.count, 2 <= pointsB.count else {
            return false
        }
        for indexA in 0 ..< pointsA.count - 1 {
            let lineA = Line(p0: pointsA[indexA], p1: pointsA[indexA + 1])
            for indexB in 0 ..< pointsB.count - 1 {
                let lineB = Line(p0: pointsB[indexB], p1: pointsB[indexB + 1])
                if lineA.intersects(lineB) {
                    return true
                }
            }
        }
        return false
    }
}
