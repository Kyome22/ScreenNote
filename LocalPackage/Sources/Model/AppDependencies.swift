import DataSource
import SwiftUI

public struct AppDependencies: Sendable {
    public var appStateClient = AppStateClient.liveValue
    public var loggingSystemClient = LoggingSystemClient.liveValue
    public var nsAppClient = NSAppClient.liveValue
    public var nsWorkspaceClient = NSWorkspaceClient.liveValue
    public var smAppServiceClient = SMAppServiceClient.liveValue
    public var spiceKeyClient = SpiceKeyClient.liveValue
    public var userDefaultsClient = UserDefaultsClient.liveValue
    public var windowSceneMessengerClient = WindowSceneMessengerClient.liveValue

    public static let shared = AppDependencies()
}

extension EnvironmentValues {
    @Entry public var appDependencies = AppDependencies.shared
}

extension AppDependencies {
    public static func testDependencies(
        appStateClient: AppStateClient = .testValue,
        loggingSystemClient: LoggingSystemClient = .testValue,
        nsAppClient: NSAppClient = .testValue,
        nsWorkspaceClient: NSWorkspaceClient = .testValue,
        smAppServiceClient: SMAppServiceClient = .testValue,
        spiceKeyClient: SpiceKeyClient = .testValue,
        userDefaultsClient: UserDefaultsClient = .testValue,
        windowSceneMessengerClient: WindowSceneMessengerClient = .testValue
    ) -> AppDependencies {
        AppDependencies(
            appStateClient: appStateClient,
            loggingSystemClient: loggingSystemClient,
            nsAppClient: nsAppClient,
            nsWorkspaceClient: nsWorkspaceClient,
            smAppServiceClient: smAppServiceClient,
            spiceKeyClient: spiceKeyClient,
            userDefaultsClient: userDefaultsClient,
            windowSceneMessengerClient: windowSceneMessengerClient
        )
    }
}
