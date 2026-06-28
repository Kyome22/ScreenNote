import CoreGraphics
import Testing

@testable import DataSource

struct GeometryTests {
    @Test(arguments: [
        (Line(p0: CGPoint(x: 0, y: 0), p1: CGPoint(x: 10, y: 10)),
         Line(p0: CGPoint(x: 0, y: 10), p1: CGPoint(x: 10, y: 0)),
         true),
        (Line(p0: CGPoint(x: 0, y: 0), p1: CGPoint(x: 10, y: 0)),
         Line(p0: CGPoint(x: 0, y: 5), p1: CGPoint(x: 10, y: 5)),
         false),
    ])
    func line_intersects(_ lineA: Line, _ lineB: Line, _ expected: Bool) {
        #expect(lineA.intersects(lineB) == expected)
    }

    @Test func curve_compute_interpolates_endpoints() {
        let curve = Curve(
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0, y: 0),
            CGPoint(x: 10, y: 10),
            CGPoint(x: 10, y: 10)
        )
        #expect(curve.compute(0.0) == CGPoint(x: 0, y: 0))
        #expect(curve.compute(1.0) == CGPoint(x: 10, y: 10))
    }

    @Test func cgPath_allPoints_walks_lines() {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 10, y: 0))
        path.addLine(to: CGPoint(x: 10, y: 10))
        #expect(path.allPoints == [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 0), CGPoint(x: 10, y: 10)])
    }

    @Test(arguments: [
        (CGPoint(x: 5, y: 4), CGFloat(4.0)),
        (CGPoint(x: -3, y: 0), CGFloat(3.0)),
    ])
    func point_distance_to_line_segment(_ point: CGPoint, _ expected: CGFloat) {
        let line = Line(p0: CGPoint(x: 0, y: 0), p1: CGPoint(x: 10, y: 0))
        #expect(point.distance(line) == expected)
    }
}
