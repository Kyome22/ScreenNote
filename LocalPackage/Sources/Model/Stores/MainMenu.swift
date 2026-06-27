import DataSource
import Foundation
import Observation

@MainActor @Observable
public final class MainMenu: Composable {
    private let appStateClient: AppStateClient
    private let nsAppClient: NSAppClient
    private let nsWorkspaceClient: NSWorkspaceClient
    private let logService: LogService

    @ObservationIgnored private var task: Task<Void, Never>?

    public var canvasVisibility: CanvasVisibility
    public let action: (Action) async -> Void

    public var environmentInfo: EnvironmentInfo {
        appStateClient.withLock(\.environmentInfo)
    }

    public init(
        _ appDependencies: AppDependencies,
        canvasVisibility: CanvasVisibility = .hidden,
        action: @escaping (Action) async -> Void = { _ in }
    ) {
        self.appStateClient = appDependencies.appStateClient
        self.nsAppClient = appDependencies.nsAppClient
        self.nsWorkspaceClient = appDependencies.nsWorkspaceClient
        self.logService = .init(appDependencies)
        self.canvasVisibility = canvasVisibility
        self.action = action
    }

    public func reduce(_ action: Action) async {
        switch action {
        case let .task(screenName):
            logService.notice(.screenView(name: screenName))
            if let canvasVisibility = appStateClient.withLock(\.canvasVisibility.latestValue) {
                self.canvasVisibility = canvasVisibility
            }
            task?.cancel()
            task = Task { [weak self, appStateClient] in
                let stream = appStateClient.withLock(\.canvasVisibility.stream)
                for await value in stream {
                    self?.canvasVisibility = value
                }
            }

        case .onDisappear:
            task?.cancel()
            task = nil

        case .canvasVisibilityButtonTapped:
            appStateClient.send(\.canvasVisibility, canvasVisibility.toggled)

        case .settingsLinkPreActionTriggered:
            nsAppClient.activate(true)

        case .aboutButtonTapped:
            nsAppClient.activate(true)
            nsAppClient.orderFrontStandardAboutPanel(nil)

        case let .reportIssueButtonTapped(content):
            guard let url = content.mailtoURL else { return }
            _ = nsWorkspaceClient.open(url)

        case .quitButtonTapped:
            nsAppClient.terminate(nil)
        }
    }

    public enum Action: Sendable {
        case task(String)
        case onDisappear
        case canvasVisibilityButtonTapped
        case settingsLinkPreActionTriggered
        case aboutButtonTapped
        case reportIssueButtonTapped(IssueReportContent)
        case quitButtonTapped

        public struct IssueReportContent: Sendable {
            var subject: String
            var body: String

            var mailtoURL: URL? {
                URL(string: "mailto:kyomesuke@icloud.com?subject=\(subject)&body=\(body)")
            }

            public init(subject: String, body: String) {
                self.subject = subject
                self.body = body
            }
        }
    }
}
