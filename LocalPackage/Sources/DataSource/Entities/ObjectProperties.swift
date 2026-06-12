import CoreGraphics

public struct ObjectProperties: Sendable, Equatable {
    public var paletteIndex: Int
    public var opacity: CGFloat
    public var lineWidth: CGFloat

    public init(paletteIndex: Int, opacity: CGFloat, lineWidth: CGFloat) {
        self.paletteIndex = paletteIndex
        self.opacity = opacity
        self.lineWidth = lineWidth
    }

    public static let `default` = Self(paletteIndex: 0, opacity: 0.8, lineWidth: 4.0)
}
