import SpiceKey

extension ModifierFlag: @retroactive Identifiable {
    public var id: Int { rawValue }
}
