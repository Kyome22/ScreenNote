import Testing

@testable import DataSource

struct AsyncStreamBundleTests {
    @Test func send_updates_latestValue() {
        var bundle = AsyncStreamBundle<Int>()
        bundle.send(42)
        #expect(bundle.latestValue == 42)
    }
}
