import Logging

public enum ErrorEvent {
    case launchAtLoginSwitchFailed(any Error)
    case donationFailed(any Error)

    public var message: Logger.Message {
        switch self {
        case .launchAtLoginSwitchFailed:
            "Failed to switch launch at login."
        case .donationFailed:
            "Donation failed."
        }
    }

    public var metadata: Logger.Metadata? {
        switch self {
        case let .launchAtLoginSwitchFailed(error):
            ["cause": "\(error.localizedDescription)"]
        case let .donationFailed(error):
            ["cause": "\(error.localizedDescription)"]
        }
    }
}
