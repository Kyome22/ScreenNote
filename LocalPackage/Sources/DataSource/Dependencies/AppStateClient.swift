import AllocatedUnfairLock

public struct AppStateClient: DependencyClient {
    var lock: AllocatedUnfairLock<AppState>

    public func withLock<R: Sendable>(_ body: @Sendable (inout AppState) throws -> R) rethrows -> R {
        try lock.withLock { try body(&$0) }
    }

    public static let liveValue = Self(lock: .init(initialState: .init()))

    public static var testValue: Self {
        Self(lock: .init(initialState: .init()))
    }

    public static func testDependency(_ appState: AllocatedUnfairLock<AppState>) -> Self {
        Self(lock: appState)
    }
}
