import Logging

public enum CriticalEvent {
    case unknown(any Error)

    public var message: Logger.Message {
        switch self {
        case .unknown:
            "An unknown error has occurred."
        }
    }

    public var metadata: Logger.Metadata? {
        switch self {
        case let .unknown(error):
            ["cause": "\(error.localizedDescription)"]
        }
    }
}
