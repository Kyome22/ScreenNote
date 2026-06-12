import DataSource
import SwiftUI

public struct AppDependencies: Sendable {
    public var appStateClient = AppStateClient.liveValue
    public var loggingSystemClient = LoggingSystemClient.liveValue
    public var mailClient = MailClient.liveValue
    public var nsApplicationClient = NSApplicationClient.liveValue
    public var smAppServiceClient = SMAppServiceClient.liveValue
    public var spiceKeyClient = SpiceKeyClient.liveValue
    public var userDefaultsClient = UserDefaultsClient.liveValue

    public static let shared = AppDependencies()
}

extension EnvironmentValues {
    @Entry public var appDependencies = AppDependencies.shared
}

extension AppDependencies {
    public static func testDependencies(
        appStateClient: AppStateClient = .testValue,
        loggingSystemClient: LoggingSystemClient = .testValue,
        mailClient: MailClient = .testValue,
        nsApplicationClient: NSApplicationClient = .testValue,
        smAppServiceClient: SMAppServiceClient = .testValue,
        spiceKeyClient: SpiceKeyClient = .testValue,
        userDefaultsClient: UserDefaultsClient = .testValue
    ) -> AppDependencies {
        AppDependencies(
            appStateClient: appStateClient,
            loggingSystemClient: loggingSystemClient,
            mailClient: mailClient,
            nsApplicationClient: nsApplicationClient,
            smAppServiceClient: smAppServiceClient,
            spiceKeyClient: spiceKeyClient,
            userDefaultsClient: userDefaultsClient
        )
    }
}
