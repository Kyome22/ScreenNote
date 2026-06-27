public enum ToolBarPosition: Int, CaseIterable, Identifiable, Sendable, Equatable {
    case top
    case right
    case bottom
    case left

    public var id: Int { rawValue }
}
