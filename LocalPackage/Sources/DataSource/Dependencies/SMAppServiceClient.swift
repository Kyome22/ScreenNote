import ServiceManagement

public struct SMAppServiceClient: DependencyClient {
    var isEnabled: @Sendable () -> Bool
    var register: @Sendable () throws -> Void
    var unregister: @Sendable () throws -> Void

    public static let liveValue = Self(
        isEnabled: { SMAppService.mainApp.status == .enabled },
        register: { try SMAppService.mainApp.register() },
        unregister: { try SMAppService.mainApp.unregister() }
    )

    public static let testValue = Self(
        isEnabled: { false },
        register: {},
        unregister: {}
    )
}
