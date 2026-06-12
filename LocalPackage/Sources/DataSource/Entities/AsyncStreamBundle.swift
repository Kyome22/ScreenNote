import AllocatedUnfairLock
import Foundation

public struct AsyncStreamBundle<T>: Sendable where T: Sendable {
    private let subscriptions = Subscriptions()
    private let replaysLatestValue: Bool
    public private(set) var latestValue: T? = nil

    public init(replaysLatestValue: Bool = true) {
        self.replaysLatestValue = replaysLatestValue
    }

    public var stream: AsyncStream<T> {
        let (stream, continuation) = AsyncStream.makeStream(
            of: T.self,
            bufferingPolicy: .bufferingNewest(1)
        )
        let replayedValue = replaysLatestValue ? latestValue : nil
        subscriptions.add(continuation, replaying: replayedValue)
        return stream
    }

    public mutating func send(_ value: T) {
        latestValue = value
        subscriptions.yield(value)
    }

    private final class Subscriptions: Sendable {
        private let continuations = AllocatedUnfairLock<[UUID: AsyncStream<T>.Continuation]>(initialState: [:])

        func add(_ continuation: AsyncStream<T>.Continuation, replaying value: T?) {
            let id = UUID()
            continuations.withLock { $0[id] = continuation }
            continuation.onTermination = { [weak self] _ in
                self?.continuations.withLock { $0[id] = nil }
            }
            if let value {
                continuation.yield(value)
            }
        }

        func yield(_ value: T) {
            for continuation in continuations.withLock({ Array($0.values) }) {
                continuation.yield(value)
            }
        }
    }
}

extension AsyncStreamBundle where T == Void {
    public mutating func send() {
        send(())
    }
}
