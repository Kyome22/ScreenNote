public enum ObjectType: Int, CaseIterable, Identifiable, Sendable, Equatable {
    case select
    case text
    case pen
    case line
    case arrow
    case fillRect
    case lineRect
    case fillOval
    case lineOval

    public var id: Int { rawValue }

    public static let defaultObjects: [ObjectType] = [
        .text, .pen, .line, .arrow, .fillRect, .lineRect, .fillOval, .lineOval,
    ]
}
