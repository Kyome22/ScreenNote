import DataSource
import SwiftUI

public struct AppDependencies: Sendable {
    public var appStateClient = AppStateClient.liveValue
    public var loggingSystemClient = LoggingSystemClient.liveValue
    public var userDefaultsClient = UserDefaultsClient.liveValue
    // MIGRATION: Phase 2/3 add nsApplicationClient, mailClient, smAppServiceClient, spiceKeyClient.

    public static let shared = AppDependencies()
}

extension EnvironmentValues {
    @Entry public var appDependencies = AppDependencies.shared
}

extension AppDependencies {
    public static func testDependencies(
        appStateClient: AppStateClient = .testValue,
        loggingSystemClient: LoggingSystemClient = .testValue,
        userDefaultsClient: UserDefaultsClient = .testValue
    ) -> AppDependencies {
        AppDependencies(
            appStateClient: appStateClient,
            loggingSystemClient: loggingSystemClient,
            userDefaultsClient: userDefaultsClient
        )
    }
}
