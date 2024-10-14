/*
  Curve.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import CoreGraphics

struct Curve {
    let p1: CGPoint
    let c1: CGPoint
    let c2: CGPoint
    let p2: CGPoint

    init(_ points: [CGPoint]) {
        assert(points.count == 4, "points need 4 points")
        p1 = points[0]
        c1 = points[1]
        c2 = points[2]
        p2 = points[3]
    }

    func compute(_ t: CGFloat) -> CGPoint {
        var point = pow(1.0 - t, 3.0) * p1
        point += (3.0 * pow(1.0 - t, 2.0) * t) * c1
        point += (3.0 * (1.0 - t) * pow(t, 2.0)) * c2
        point += pow(t, 3.0) * p2
        return point
    }

    var points: [CGPoint] {
        (0 ..< 10).map { compute(CGFloat($0 + 1) / 10.0) }
    }
}
