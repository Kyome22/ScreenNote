import CoreGraphics
import Testing

@testable import DataSource

struct ObjectTests {
    @Test func bounds_spans_all_points() {
        let object = Object(.pen, 0, 1.0, 4.0, [
            CGPoint(x: 10, y: 20),
            CGPoint(x: 50, y: 5),
            CGPoint(x: 30, y: 40),
        ])
        #expect(object.bounds == CGRect(x: 10, y: 5, width: 40, height: 35))
    }

    @Test func isHit_point_on_line_within_radius() {
        let object = Object(.line, 0, 1.0, 4.0, [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 0)])
        #expect(object.isHit(point: CGPoint(x: 50, y: 3)) == true)
        #expect(object.isHit(point: CGPoint(x: 50, y: 10)) == false)
    }

    @Test func isHit_point_inside_fillRect() {
        let object = Object(.fillRect, 0, 1.0, 4.0, [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 100)])
        #expect(object.isHit(point: CGPoint(x: 50, y: 50)) == true)
        #expect(object.isHit(point: CGPoint(x: 150, y: 50)) == false)
    }

    @Test func isHit_rect_containing_object() {
        let object = Object(.fillOval, 0, 1.0, 4.0, [CGPoint(x: 10, y: 10), CGPoint(x: 20, y: 20)])
        #expect(object.isHit(rect: CGRect(x: 0, y: 0, width: 100, height: 100)) == true)
    }

    @Test func isHit_rect_intersecting_line() {
        let object = Object(.line, 0, 1.0, 4.0, [CGPoint(x: 0, y: 0), CGPoint(x: 100, y: 100)])
        #expect(object.isHit(rect: CGRect(x: 40, y: 40, width: 20, height: 20)) == true)
        #expect(object.isHit(rect: CGRect(x: 80, y: 0, width: 10, height: 10)) == false)
    }

    @Test func isHit_rect_empty_returns_false() {
        let object = Object(.fillRect, 0, 1.0, 4.0, [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 10)])
        #expect(object.isHit(rect: CGRect(x: 5, y: 5, width: 0, height: 0)) == false)
    }

    @Test func copy_with_offset_shifts_points_and_selects() {
        let object = Object(.pen, 3, 0.5, 2.0, [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 10)])
        let copied = object.copy(needsOffset: true)
        #expect(copied.points == [CGPoint(x: 20, y: 20), CGPoint(x: 30, y: 30)])
        #expect(copied.isSelected == true)
        #expect(copied.id != object.id)
        #expect(copied.paletteIndex == 3)
    }

    @Test func copy_text_object_keeps_text_and_orientation() {
        let object = Object(2, 0.8, [CGPoint(x: 0, y: 0), CGPoint(x: 40, y: 20)], "hello", .right)
        let copied = object.copy()
        #expect(copied.type == .text)
        #expect(copied.text == "hello")
        #expect(copied.textOrientation == .right)
        #expect(copied.points == object.points)
    }

    @Test func pen_with_single_point_hits_as_dot() {
        let object = Object(.pen, 0, 1.0, 8.0, [CGPoint(x: 50, y: 50)])
        #expect(object.bounds.isEmpty)
        #expect(object.cgPath.boundingBox.width == 8.0)
    }
}
