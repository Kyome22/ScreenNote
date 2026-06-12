public enum ToggleMethod: Int, CaseIterable, Identifiable, Sendable, Equatable {
    case longPressKey
    case pressBothSideKeys

    public var id: Int { rawValue }
}
