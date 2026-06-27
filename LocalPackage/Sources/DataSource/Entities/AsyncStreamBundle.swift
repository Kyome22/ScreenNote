import AsyncAlgorithms

public typealias AsyncShareStream<T: Sendable> = Sendable & AsyncSequence<T, AsyncStream<T>.__AsyncSequence_Failure>

public struct AsyncStreamBundle<T>: Sendable where T: Sendable {
    public let stream: any AsyncShareStream<T>
    private let continuation: AsyncStream<T>.Continuation
    public private(set) var latestValue: T? = nil

    public init() {
        let (stream, continuation) = AsyncStream.makeStream(
            of: T.self,
            bufferingPolicy: .bufferingNewest(1)
        )
        self.stream = stream.share(bufferingPolicy: .bufferingLatest(1))
        self.continuation = continuation
    }

    public mutating func send(_ value: T) {
        latestValue = value
        continuation.yield(value)
    }
}

extension AsyncStreamBundle where T == Void {
    public mutating func send() {
        send(())
    }
}
