public enum CanvasVisibility: Sendable, Equatable {
    case visible
    case hidden

    public var toggled: Self {
        switch self {
        case .visible:
            CanvasVisibility.hidden
        case .hidden:
            CanvasVisibility.visible
        }
    }
}
