import CoreGraphics

public enum RotateMethod: Int, CaseIterable, Identifiable, Sendable, Equatable {
    case rotateRight
    case rotateLeft

    public var id: Int { rawValue }

    public var angle: CGFloat {
        (self == .rotateRight ? 0.5 : -0.5) * CGFloat.pi
    }
}
