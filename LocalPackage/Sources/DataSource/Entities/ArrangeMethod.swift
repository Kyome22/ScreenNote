public enum ArrangeMethod: Int, CaseIterable, Identifiable, Sendable, Equatable {
    case bringToFrontmost
    case sendToBackmost

    public var id: Int { rawValue }
}
