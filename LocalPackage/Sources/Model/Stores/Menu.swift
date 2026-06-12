import DataSource
import Foundation
import Observation

@MainActor @Observable
public final class Menu: Composable {
    private let appStateClient: AppStateClient
    private let nsApplicationClient: NSApplicationClient
    private let mailClient: MailClient
    private let logService: LogService
    @ObservationIgnored private var observationTask: Task<Void, Never>?

    public var canvasVisible: CanvasVisible
    public let action: (Action) async -> Void

    public init(
        _ appDependencies: AppDependencies,
        canvasVisible: CanvasVisible? = nil,
        action: @escaping (Action) async -> Void = { _ in }
    ) {
        self.appStateClient = appDependencies.appStateClient
        self.nsApplicationClient = appDependencies.nsApplicationClient
        self.mailClient = appDependencies.mailClient
        self.logService = .init(appDependencies)
        self.canvasVisible = canvasVisible
            ?? appDependencies.appStateClient.withLock(\.canvasVisible.latestValue)
            ?? .hide
        self.action = action
    }

    public func reduce(_ action: Action) async {
        switch action {
        case let .task(screenName):
            logService.notice(.screenView(name: screenName))
            observeCanvasVisible()

        case .onDisappear:
            observationTask?.cancel()
            observationTask = nil

        case .showOrHideCanvasButtonTapped:
            appStateClient.withLock { $0.shortcutCommand.send() }

        case .settingsLinkPreActionTriggered:
            nsApplicationClient.activate()

        case .aboutButtonTapped:
            nsApplicationClient.orderFrontAboutPanel()

        case let .reportIssueButtonTapped(subject, body):
            mailClient.compose(["kyomesuke@icloud.com"], subject, body)

        case .quitButtonTapped:
            nsApplicationClient.terminate()
        }
    }

    private func observeCanvasVisible() {
        observationTask?.cancel()
        if let latestValue = appStateClient.withLock(\.canvasVisible.latestValue) {
            canvasVisible = latestValue
        }
        let appStateClient = self.appStateClient
        observationTask = Task { [weak self] in
            let stream = appStateClient.withLock(\.canvasVisible.stream)
            for await value in stream {
                self?.canvasVisible = value
            }
        }
    }

    public enum Action: Sendable {
        case task(String)
        case onDisappear
        case showOrHideCanvasButtonTapped
        case settingsLinkPreActionTriggered
        case aboutButtonTapped
        case reportIssueButtonTapped(subject: String, body: [String])
        case quitButtonTapped
    }
}
