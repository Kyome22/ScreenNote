import AppKit

public struct NSWorkspaceClient: DependencyClient {
    public var open: @Sendable (URL) -> Bool

    public static let liveValue = Self(
        open: { NSWorkspace.shared.open($0) }
    )

    public static let testValue = Self(
        open: { _ in false }
    )
}
