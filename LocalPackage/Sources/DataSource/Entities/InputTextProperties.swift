import CoreGraphics

public struct InputTextProperties: Sendable, Equatable {
    public var object: Object
    public var inputText: String
    public var fontSize: CGFloat

    public init(object: Object, inputText: String, fontSize: CGFloat) {
        self.object = object
        self.inputText = inputText
        self.fontSize = fontSize
    }

    public var inputTextOffset: CGSize {
        CGSize(width: object.bounds.minX, height: object.bounds.minY)
    }
}
