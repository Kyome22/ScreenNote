import CoreGraphics
import Testing

@testable import DataSource

struct ObjectTests {
    @Test(arguments: [
        (CGPoint(x: 50, y: 3), true),
        (CGPoint(x: 50, y: 10), false),
    ])
    func isHit_point_on_line_within_radius(_ point: CGPoint, _ expected: Bool) {
        let object = Object(.line, 0, 1.0, 4.0, [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0)])
        #expect(object.isHit(point: point) == expected)
    }

    @Test(arguments: [
        (CGRect(x: 40, y: 40, width: 20, height: 20), true),
        (CGRect(x: 80, y: 0, width: 10, height: 10), false),
    ])
    func isHit_rect_intersecting_line(_ rect: CGRect, _ expected: Bool) {
        let object = Object(.line, 0, 1.0, 4.0, [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 100)])
        #expect(object.isHit(rect: rect) == expected)
    }
}
