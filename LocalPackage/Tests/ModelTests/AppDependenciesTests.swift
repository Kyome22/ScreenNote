import Testing

@testable import Model

struct AppDependenciesTests {
    @Test func testDependencies_returns_test_values() {
        let appDependencies = AppDependencies.testDependencies()
        #expect(appDependencies.appStateClient.withLock(\.hasAlreadyBootstrap) == false)
    }
}
