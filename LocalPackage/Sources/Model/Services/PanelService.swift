import DataSource
import WindowSceneKit

struct PanelService {
    private let nsAppClient: NSAppClient
    private let windowSceneMessengerClient: WindowSceneMessengerClient
    private let userDefaultsRepository: UserDefaultsRepository

    init(_ appDependencies: AppDependencies) {
        nsAppClient = appDependencies.nsAppClient
        windowSceneMessengerClient = appDependencies.windowSceneMessengerClient
        userDefaultsRepository = .init(appDependencies.userDefaultsClient)
    }

    func showTriggerMethodPanel() {
        if userDefaultsRepository.showsTriggerMethod {
            windowSceneMessengerClient.request(.open, .triggerMethodPanel)
        }
    }

    func hideTriggerMethodPanel() {
        if userDefaultsRepository.showsTriggerMethod {
            windowSceneMessengerClient.request(.close, .triggerMethodPanel)
        }
    }

    @MainActor
    func toggleWorkspacePanel(to visivility: CanvasVisibility) {
        switch visivility {
        case .visible:
            windowSceneMessengerClient.request(.open, .workspacePanel)
            nsAppClient.activate(true)
        case .hidden:
            windowSceneMessengerClient.request(.close, .workspacePanel)
        }
    }
}
