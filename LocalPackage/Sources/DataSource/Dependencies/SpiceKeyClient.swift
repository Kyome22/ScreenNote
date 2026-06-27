import Foundation
import SpiceKey

public struct SpiceKeyClient: DependencyClient {
    public var register: @Sendable (SpiceKey) -> Void
    public var unregister: @Sendable (SpiceKey) -> Void

    public static let liveValue = Self(
        register: { $0.register() },
        unregister: { $0.unregister() }
    )

    public static let testValue = Self(
        register: { _ in },
        unregister: { _ in }
    )
}
