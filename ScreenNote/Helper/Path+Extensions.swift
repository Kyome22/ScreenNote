/*
  Path+Extensions.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/02.
  
*/

import SwiftUI

extension Path {
    static func anchorPaths(bounds: CGRect) -> [Path] {
        let offset = CGPoint(4.0)
        let size = CGSize(8.0)
        if bounds.isEmpty {
            let origin = bounds.origin - offset
            return [Path(CGRect(origin: origin, size: size))]
        }
        return Anchor.allCases.map { anchor in
            let origin = anchor.center(with: bounds) - offset
            return Path(CGRect(origin: origin, size: size))
        }
    }

    var allPoints: [CGPoint] {
        var points = [CGPoint]()
        self.cgPath.applyWithBlock { element in
            switch element.pointee.type {
            case CGPathElementType.moveToPoint:
                points.append(element.pointee.points[0])
            case CGPathElementType.addLineToPoint:
                points.append(element.pointee.points[0])
            case CGPathElementType.addCurveToPoint:
                guard let point = points.last else { break }
                let curve = Curve([point,
                                   element.pointee.points[0],
                                   element.pointee.points[1],
                                   element.pointee.points[2]])
                points.append(contentsOf: curve.points)
            case CGPathElementType.addQuadCurveToPoint:
                guard let point = points.last else { break }
                let curve = Curve([point,
                                   element.pointee.points[0],
                                   element.pointee.points[0],
                                   element.pointee.points[1]])
                points.append(contentsOf: curve.points)
            case CGPathElementType.closeSubpath:
                guard let point = points.first else { break }
                points.append(point)
            @unknown default:
                fatalError("impossible")
            }
        }
        return points
    }

    func intersects(with point: CGPoint, radius: CGFloat) -> Bool {
        let points = self.allPoints
        if points.count < 2 { return false }
        for i in (0 ..< points.count - 1) {
            if point.distance(Line(p0: points[i], p1: points[i + 1])) < radius {
                return true
            }
        }
        return false
    }

    func intersects(_ path: Path) -> Bool {
        let pointsA = self.allPoints
        let pointsB = path.allPoints
        if pointsA.count < 2 || pointsB.count < 2 { return false }
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
