import AllocatedUnfairLock
import Testing
@testable import DataSource

private enum TestError: Error {
    case registrationFailed
}

struct LaunchAtLoginRepositoryTests {
    @Test func switchStatus_success_when_register_enables() {
        let enabled = AllocatedUnfairLock<Bool>(initialState: false)
        let client = testDependency(of: SMAppServiceClient.self) { client in
            client.isEnabled = { enabled.withLock(\.self) }
            client.register = { enabled.withLock { $0 = true } }
            client.unregister = { enabled.withLock { $0 = false } }
        }
        let repository = LaunchAtLoginRepository(client)
        let result = repository.switchStatus(true)
        let isSuccess = if case .success = result { true } else { false }
        #expect(isSuccess)
        #expect(repository.isEnabled == true)
    }

    @Test func switchStatus_failure_returns_current_when_register_throws() {
        let client = testDependency(of: SMAppServiceClient.self) { client in
            client.isEnabled = { false }
            client.register = { throw TestError.registrationFailed }
            client.unregister = {}
        }
        let repository = LaunchAtLoginRepository(client)
        let result = repository.switchStatus(true)
        let failedValue: Bool? = if case let .failure(.switchFailed(value)) = result { value } else { nil }
        #expect(failedValue == false)
    }
}
