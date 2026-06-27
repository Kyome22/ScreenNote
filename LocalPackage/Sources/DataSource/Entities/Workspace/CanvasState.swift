import CoreGraphics

public struct CanvasState: Sendable, Equatable {
    public var objects: [Object]
    public var objectType: ObjectType
    public var objectProperties: ObjectProperties
    public var inputTextProperties: InputTextProperties?
    public var rectangleForSelection: Object?

    public init(
        objects: [Object] = [],
        objectType: ObjectType = .pen,
        objectProperties: ObjectProperties = .default,
        inputTextProperties: InputTextProperties? = nil,
        rectangleForSelection: Object? = nil
    ) {
        self.objects = objects
        self.objectType = objectType
        self.objectProperties = objectProperties
        self.inputTextProperties = inputTextProperties
        self.rectangleForSelection = rectangleForSelection
    }

    public var selectedObjects: [Object] {
        objects.filter(\.isSelected)
    }

    public var selectedObjectsBounds: CGRect? {
        Self.bounds(of: selectedObjects)
    }

    public var isSelecting: Bool {
        objectType == .select && selectedObjectsBounds != nil
    }

    public static func bounds(of objects: [Object]) -> CGRect? {
        objects.reduce(CGRect?.none) { partialResult, object in
            partialResult?.union(object.bounds) ?? object.bounds
        }
    }
}
