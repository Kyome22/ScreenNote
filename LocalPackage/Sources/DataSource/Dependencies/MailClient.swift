import AppKit

public struct MailClient: DependencyClient {
    public var compose: @Sendable (_ recipients: [String], _ subject: String, _ items: [String]) -> Void

    public static let liveValue = Self(
        compose: { recipients, subject, items in
            MainActor.assumeIsolated {
                guard let service = NSSharingService(named: .composeEmail) else { return }
                service.recipients = recipients
                service.subject = subject
                service.perform(withItems: items)
            }
        }
    )

    public static let testValue = Self(
        compose: { _, _, _ in }
    )
}
