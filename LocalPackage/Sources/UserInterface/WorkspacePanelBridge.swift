import AppKit
import DataSource
import Model

@MainActor
public final class WorkspacePanelBridge: NSObject, NSWindowDelegate {
    private let appDependencies: AppDependencies
    private let appStateClient: AppStateClient
    private let nsApplicationClient: NSApplicationClient
    private let objectService: ObjectService
    private let userDefaultsRepository: UserDefaultsRepository

    private var workspacePanel: WorkspacePanel?
    private var shortcutPanel: ShortcutPanel?
    private var lifecycleTasks = [Task<Void, Never>]()
    private var hasStarted = false

    public init(_ appDependencies: AppDependencies = .shared) {
        self.appDependencies = appDependencies
        self.appStateClient = appDependencies.appStateClient
        self.nsApplicationClient = appDependencies.nsApplicationClient
        self.objectService = .init(appDependencies)
        self.userDefaultsRepository = .init(
            appDependencies.userDefaultsClient,
            appDependencies.appStateClient
        )
        super.init()
    }

    public func start() {
        guard !hasStarted else { return }
        hasStarted = true
        if userDefaultsRepository.showToggleMethod {
            fadeInShortcutPanel()
        }
        let appStateClient = self.appStateClient
        lifecycleTasks = [
            Task { [weak self] in
                for await _ in appStateClient.withLock(\.shortcutCommand.stream) {
                    self?.toggleCanvas()
                }
            },
        ]
    }

    public func fadeOutShortcutPanel() {
        shortcutPanel?.fadeOut()
    }

    public func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        if window === shortcutPanel {
            shortcutPanel = nil
        } else if window === workspacePanel {
            workspacePanel = nil
        }
    }

    private func toggleCanvas() {
        if workspacePanel == nil {
            showCanvas()
        } else {
            hideCanvas()
        }
    }

    private func showCanvas() {
        fadeOutShortcutPanel()
        guard workspacePanel == nil else { return }
        if userDefaultsRepository.clearAllObjects {
            objectService.resetHistory()
        }
        objectService.resetDefaultSettings()
        let panel = WorkspacePanel(appDependencies)
        panel.delegate = self
        panel.fadeIn()
        workspacePanel = panel
        appStateClient.withLock { $0.canvasVisible.send(.show) }
        nsApplicationClient.activate()
    }

    private func hideCanvas() {
        workspacePanel?.fadeOut()
        appStateClient.withLock { $0.canvasVisible.send(.hide) }
    }

    private func fadeInShortcutPanel() {
        guard shortcutPanel == nil else { return }
        let panel = ShortcutPanel(
            userDefaultsRepository.toggleMethod,
            userDefaultsRepository.modifierFlag
        )
        panel.delegate = self
        panel.fadeIn()
        shortcutPanel = panel
    }
}
