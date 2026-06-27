public struct EnvironmentInfo: Sendable {
    public var appName: String
    public var appVersion: String
    public var deviceName: String
    public var systemVersion: String

    public init(appName: String, appVersion: String, deviceName: String, systemVersion: String) {
        self.appName = appName
        self.appVersion = appVersion
        self.deviceName = deviceName
        self.systemVersion = systemVersion
    }

    public var items: [String] {
        [appName, appVersion, deviceName, systemVersion]
    }

    static let unknown = EnvironmentInfo(
        appName: "Unknown",
        appVersion: "Unknown",
        deviceName: "Unknown",
        systemVersion: "Unknown"
    )
}
