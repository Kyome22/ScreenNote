import Foundation

public struct IssueReportContent: Sendable {
    public var subject: String
    public var body: String

    public init(subject: String, body: String) {
        self.subject = subject
        self.body = body
    }
}
