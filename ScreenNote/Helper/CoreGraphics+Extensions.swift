/*
 CoreGraphics+Extensions.swift
 ScreenNote

 Created by Takuto Nakamura on 2023/01/30.

 */

import CoreGraphics

extension CGPoint {
    init(_ scalar: CGFloat) {
        self.init(x: scalar, y: scalar)
    }

    func length(from: CGPoint) -> CGFloat {
        return sqrt(pow(self.x - from.x, 2.0) + pow(self.y - from.y, 2.0))
    }

    func radian(from: CGPoint) -> CGFloat {
        return atan2(self.y - from.y, self.x - from.x)
    }

    func distance(_ line: Line) -> CGFloat {
        let lenX = line.p0.x - line.p1.x
        let lenY = line.p0.y - line.p1.y
        let sx = line.p0.x - self.x
        let sy = line.p0.y - self.y
        let s1 = lenX * sx + lenY * sy
        if s1 <= 0 {
            return (sx * sx + sy * sy).squareRoot()
        }
        let ex = self.x - line.p1.x
        let ey = self.y - line.p1.y
        let s2 = lenX * ex + lenY * ey
        if s2 <= 0 {
            return (ex * ex + ey * ey).squareRoot()
        }
        return abs(lenX * sy - lenY * sx) / (s1 + s2).squareRoot()
    }
}

extension CGSize {
    init(_ side: CGFloat) {
        self.init(width: side, height: side)
    }
}
