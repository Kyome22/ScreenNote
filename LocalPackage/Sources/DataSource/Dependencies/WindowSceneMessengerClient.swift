import WindowSceneKit

public struct WindowSceneMessengerClient: DependencyClient {
    public var request: @Sendable (WindowAction, WindowSceneKey<Void>) -> Void

    public static let liveValue = Self(
        request: { WindowSceneMessenger.request($0, for: $1, payload: nil) }
    )

    public static let testValue = Self(
        request: { _, _ in }
    )
}
