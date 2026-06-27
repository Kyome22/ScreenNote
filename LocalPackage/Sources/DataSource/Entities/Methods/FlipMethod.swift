public enum FlipMethod: Int, CaseIterable, Identifiable, Sendable, Equatable {
    case flipHorizontal
    case flipVertical

    public var id: Int { rawValue }
}
