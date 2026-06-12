import SpiceKey

extension ModifierFlag: @retroactive @unchecked Sendable {}

extension ModifierFlag: @retroactive Identifiable {
    public var id: Int { rawValue }
}
