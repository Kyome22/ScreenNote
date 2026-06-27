import AllocatedUnfairLock

public struct AppStateClient: DependencyClient {
    private let lock: AllocatedUnfairLock<AppState>

    init(lock: AllocatedUnfairLock<AppState>) {
        self.lock = lock
    }

    public func withLock<R: Sendable>(_ body: @Sendable (inout AppState) throws -> R) rethrows -> R {
        try lock.withLock(body)
    }

    public func send<T: Sendable>(
        _ keyPath: any WritableKeyPath<AppState, AsyncStreamBundle<T>> & Sendable,
        _ value: T
    ) {
        lock.withLock { $0[keyPath: keyPath].send(value) }
    }

    public func send<T: Sendable>(
        _ keyPath: any WritableKeyPath<AppState, AsyncStreamBundle<T>> & Sendable,
        default defaultValue: @autoclosure @Sendable () -> T,
        _ transform: @Sendable (inout T) -> Void
    ) {
        lock.withLock { appState in
            var value = appState[keyPath: keyPath].latestValue ?? defaultValue()
            transform(&value)
            appState[keyPath: keyPath].send(value)
        }
    }

    public static let liveValue = Self(lock: .init(initialState: .init()))

    public static let testValue = Self(lock: .init(initialState: .init()))

    public static func testDependency(_ appState: AllocatedUnfairLock<AppState>) -> Self {
        Self(lock: appState)
    }
}
