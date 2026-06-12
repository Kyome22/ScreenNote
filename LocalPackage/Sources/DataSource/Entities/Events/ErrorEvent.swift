import Logging

public enum ErrorEvent {
    case launchAtLoginSwitchFailed(any Error)

    public var message: Logger.Message {
        switch self {
        case .launchAtLoginSwitchFailed:
            "Failed to switch launch at login."
        }
    }

    public var metadata: Logger.Metadata? {
        switch self {
        case let .launchAtLoginSwitchFailed(error):
            ["cause": "\(error.localizedDescription)"]
        }
    }
}
