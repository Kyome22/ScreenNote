public struct LaunchAtLoginRepository: Sendable {
    private let smAppServiceClient: SMAppServiceClient

    public var isEnabled: Bool {
        smAppServiceClient.isEnabled()
    }

    public init(_ smAppServiceClient: SMAppServiceClient) {
        self.smAppServiceClient = smAppServiceClient
    }

    public func switchStatus(_ isOn: Bool) -> Result<Void, SwitchError> {
        do {
            if isOn {
                try smAppServiceClient.register()
            } else {
                try smAppServiceClient.unregister()
            }
        } catch {
            let current = smAppServiceClient.isEnabled()
            return .failure(.switchFailed(current))
        }
        let current = smAppServiceClient.isEnabled()
        if current != isOn {
            return .failure(.switchFailed(current))
        }
        return .success(())
    }

    public enum SwitchError: Error, Equatable {
        case switchFailed(Bool)
    }
}
