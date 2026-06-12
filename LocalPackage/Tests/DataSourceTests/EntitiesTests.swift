import CoreGraphics
import Testing

@testable import DataSource

struct TextOrientationTests {
    @Test func rotate_right_cycles_plain_orientations() {
        #expect(TextOrientation.up.rotate(.rotateRight) == .right)
        #expect(TextOrientation.right.rotate(.rotateRight) == .down)
        #expect(TextOrientation.down.rotate(.rotateRight) == .left)
        #expect(TextOrientation.left.rotate(.rotateRight) == .up)
    }

    @Test func rotate_left_reverses_rotate_right() {
        for orientation in TextOrientation.allCases {
            #expect(orientation.rotate(.rotateRight).rotate(.rotateLeft) == orientation)
        }
    }

    @Test func flip_twice_restores_orientation() {
        for orientation in TextOrientation.allCases {
            #expect(orientation.flip(.flipHorizontal).flip(.flipHorizontal) == orientation)
            #expect(orientation.flip(.flipVertical).flip(.flipVertical) == orientation)
        }
    }

    @Test func size_swaps_dimensions_for_sideways_orientations() {
        let bounds = CGRect(x: 0, y: 0, width: 30, height: 10)
        #expect(TextOrientation.up.size(of: bounds) == CGSize(width: 30, height: 10))
        #expect(TextOrientation.right.size(of: bounds) == CGSize(width: 10, height: 30))
    }

    @Test func endPosition_up_extends_right_and_down() {
        let end = TextOrientation.up.endPosition(with: CGPoint(x: 10, y: 20), size: CGSize(width: 30, height: 40))
        #expect(end == CGPoint(x: 40, y: 60))
    }
}

struct AnchorTests {
    @Test func resize_bottomRight_grows_size() {
        let bounds = CGRect(x: 0, y: 0, width: 100, height: 50)
        let resized = Anchor.bottomRight.resize(bounds: bounds, with: CGPoint(x: 10, y: 20))
        #expect(resized == CGRect(x: 0, y: 0, width: 110, height: 70))
    }

    @Test func resize_topLeft_moves_origin_and_shrinks() {
        let bounds = CGRect(x: 0, y: 0, width: 100, height: 50)
        let resized = Anchor.topLeft.resize(bounds: bounds, with: CGPoint(x: 10, y: 20))
        #expect(resized == CGRect(x: 10, y: 20, width: 90, height: 30))
    }

    @Test func rects_returns_one_rect_for_empty_bounds() {
        let rects = Anchor.rects(bounds: CGRect(origin: CGPoint(x: 50, y: 50), size: .zero))
        #expect(rects == [CGRect(x: 46, y: 46, width: 8, height: 8)])
    }

    @Test func hitAnchor_finds_anchor_under_point() {
        let bounds = CGRect(x: 0, y: 0, width: 100, height: 100)
        #expect(Anchor.hitAnchor(of: CGPoint(x: 0, y: 0), in: bounds) == .topLeft)
        #expect(Anchor.hitAnchor(of: CGPoint(x: 100, y: 100), in: bounds) == .bottomRight)
        #expect(Anchor.hitAnchor(of: CGPoint(x: 50, y: 50), in: bounds) == nil)
    }
}

struct CanvasStateTests {
    @Test func selectedObjectsBounds_unions_selected_objects() {
        var state = CanvasState()
        state.objects = [
            Object(.fillRect, 0, 1.0, 4.0, [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 10)], isSelected: true),
            Object(.fillRect, 0, 1.0, 4.0, [CGPoint(x: 20, y: 20), CGPoint(x: 30, y: 30)], isSelected: true),
            Object(.fillRect, 0, 1.0, 4.0, [CGPoint(x: 90, y: 90), CGPoint(x: 99, y: 99)]),
        ]
        #expect(state.selectedObjectsBounds == CGRect(x: 0, y: 0, width: 30, height: 30))
    }

    @Test func isSelecting_requires_select_tool_and_selection() {
        var state = CanvasState()
        state.objects = [
            Object(.fillRect, 0, 1.0, 4.0, [CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 10)], isSelected: true),
        ]
        state.objectType = .pen
        #expect(state.isSelecting == false)
        state.objectType = .select
        #expect(state.isSelecting == true)
    }
}

struct GeometryTests {
    @Test func line_intersects_crossing_line() {
        let lineA = Line(p0: CGPoint(x: 0, y: 0), p1: CGPoint(x: 10, y: 10))
        let lineB = Line(p0: CGPoint(x: 0, y: 10), p1: CGPoint(x: 10, y: 0))
        #expect(lineA.intersects(lineB) == true)
    }

    @Test func line_does_not_intersect_parallel_line() {
        let lineA = Line(p0: CGPoint(x: 0, y: 0), p1: CGPoint(x: 10, y: 0))
        let lineB = Line(p0: CGPoint(x: 0, y: 5), p1: CGPoint(x: 10, y: 5))
        #expect(lineA.intersects(lineB) == false)
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

    @Test func point_distance_to_line_segment() {
        let line = Line(p0: CGPoint(x: 0, y: 0), p1: CGPoint(x: 10, y: 0))
        #expect(CGPoint(x: 5, y: 4).distance(line) == 4.0)
        #expect(CGPoint(x: -3, y: 0).distance(line) == 3.0)
    }
}
