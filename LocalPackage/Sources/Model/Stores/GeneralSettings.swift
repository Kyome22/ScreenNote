import DataSource
import Observation
import SpiceKey

@MainActor @Observable
public final class GeneralSettings: Composable {
    private let launchAtLoginRepository: LaunchAtLoginRepository
    private let userDefaultsRepository: UserDefaultsRepository
    private let logService: LogService
    private let shortcutService: ShortcutService

    public var triggerMethod: TriggerMethod
    public var modifierFlag: ModifierFlag
    public var longPressDuration: Double
    public var toolBarPosition: ToolBarPosition
    public var launchesAtLogin: Bool
    public var showsTriggerMethod: Bool
    public let action: (Action) async -> Void

    public init(
        _ appDependencies: AppDependencies,
        triggerMethod: TriggerMethod? = nil,
        modifierFlag: ModifierFlag? = nil,
        longPressDuration: Double? = nil,
        toolBarPosition: ToolBarPosition? = nil,
        launchesAtLogin: Bool? = nil,
        showsTriggerMethod: Bool? = nil,
        action: @escaping (Action) async -> Void = { _ in }
    ) {
        self.launchAtLoginRepository = .init(appDependencies.smAppServiceClient)
        self.userDefaultsRepository = .init(appDependencies.userDefaultsClient)
        self.logService = .init(appDependencies)
        self.shortcutService = .init(appDependencies)
        self.triggerMethod = triggerMethod ?? userDefaultsRepository.triggerMethod
        self.modifierFlag = modifierFlag ?? userDefaultsRepository.modifierFlag
        self.longPressDuration = longPressDuration ?? userDefaultsRepository.longPressDuration
        self.toolBarPosition = toolBarPosition ?? userDefaultsRepository.toolBarPosition
        self.launchesAtLogin = launchesAtLogin ?? launchAtLoginRepository.isEnabled
        self.showsTriggerMethod = showsTriggerMethod ?? userDefaultsRepository.showsTriggerMethod
        self.action = action
    }

    public func reduce(_ action: Action) async {
        switch action {
        case let .task(screenName):
            logService.notice(.screenView(name: screenName))

        case let .triggerMethodPickerSelected(triggerMethod):
            self.triggerMethod = triggerMethod
            userDefaultsRepository.triggerMethod = triggerMethod
            shortcutService.register()

        case let .modifierFlagPickerSelected(modifierFlag):
            self.modifierFlag = modifierFlag
            userDefaultsRepository.modifierFlag = modifierFlag
            shortcutService.register()

        case let .longPressDurationChanged(editing):
            guard !editing else { return }
            userDefaultsRepository.longPressDuration = longPressDuration
            shortcutService.register()

        case let .toolBarPositionPickerSelected(toolBarPosition):
            self.toolBarPosition = toolBarPosition
            userDefaultsRepository.toolBarPosition = toolBarPosition

        case let .launchAtLoginToggleSwitched(isOn):
            switch launchAtLoginRepository.switchStatus(isOn) {
            case .success:
                launchesAtLogin = isOn
            case let .failure(.switchFailed(value)):
                launchesAtLogin = value
            }

        case let .showTriggerMethodToggleSwitched(isOn):
            showsTriggerMethod = isOn
            userDefaultsRepository.showsTriggerMethod = isOn
        }
    }

    public enum Action: Sendable {
        case task(String)
        case triggerMethodPickerSelected(TriggerMethod)
        case modifierFlagPickerSelected(ModifierFlag)
        case longPressDurationChanged(Bool)
        case toolBarPositionPickerSelected(ToolBarPosition)
        case launchAtLoginToggleSwitched(Bool)
        case showTriggerMethodToggleSwitched(Bool)
    }
}
