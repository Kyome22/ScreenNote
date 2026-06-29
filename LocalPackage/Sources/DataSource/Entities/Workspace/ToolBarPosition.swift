public enum ToolBarPosition: Int, CaseIterable, Identifiable, Sendable, Equatable {
    case top
    case right
    case bottom
    case left

    public var id: Int { rawValue }

    public var direction: ToolBarDirection {
        switch self {
        case .top, .bottom:
            ToolBarDirection.horizontal
        case .right, .left:
            ToolBarDirection.vertical
        }
    }
}
