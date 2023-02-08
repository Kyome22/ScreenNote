/*
  Line.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import CoreGraphics

struct Line {
    let p0: CGPoint
    let p1: CGPoint

    init(p0: CGPoint, p1: CGPoint) {
        self.p0 = p0
        self.p1 = p1
    }

    func intersects(_ line: Line) -> Bool {
        let p = (p0.x - p1.x) * (line.p0.y - p0.y) - (p0.y - p1.y) * (line.p0.x - p0.x)
        let q = (p0.x - p1.x) * (line.p1.y - p0.y) - (p0.y - p1.y) * (line.p1.x - p0.x)
        if 0 < p * q {
            return false
        }
        let r = (line.p0.x - line.p1.x) * (p0.y - line.p0.y) - (line.p0.y - line.p1.y) * (p0.x - line.p0.x)
        let s = (line.p0.x - line.p1.x) * (p1.y - line.p0.y) - (line.p0.y - line.p1.y) * (p1.x - line.p0.x)
        if 0 < r * s {
            return false
        }
        return true
    }
}
