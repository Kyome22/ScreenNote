import CoreGraphics

public struct DragContext: Sendable, Equatable {
    public enum DragAction: Sendable, Equatable {
        case none
        case move
        case resize
    }

    public enum SelectType: Sendable, Equatable {
        case rectangle
        case selectOne(Int)
        case keep
    }

    public var action: DragAction
    public var anchor: Anchor
    public var selectType: SelectType
    public var lastObjects: [Object]

    public init(
        action: DragAction = .none,
        anchor: Anchor = .topLeft,
        selectType: SelectType = .rectangle,
        lastObjects: [Object] = []
    ) {
        self.action = action
        self.anchor = anchor
        self.selectType = selectType
        self.lastObjects = lastObjects
    }
}
