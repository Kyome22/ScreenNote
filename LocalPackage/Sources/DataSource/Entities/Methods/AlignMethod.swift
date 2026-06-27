public enum AlignMethod: Int, CaseIterable, Identifiable, Sendable, Equatable {
    case horizontalAlignLeft
    case horizontalAlignCenter
    case horizontalAlignRight
    case verticalAlignTop
    case verticalAlignCenter
    case verticalAlignBottom

    public var id: Int { rawValue }

    public static let horizontals: [AlignMethod] = [
        .horizontalAlignLeft, .horizontalAlignCenter, .horizontalAlignRight,
    ]

    public static let verticals: [AlignMethod] = [
        .verticalAlignTop, .verticalAlignCenter, .verticalAlignBottom,
    ]
}
