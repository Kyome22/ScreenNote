import DataSource
import Observation
import SpiceKey

@MainActor @Observable
public final class GeneralSettings: Composable {
    private let userDefaultsRepository: UserDefaultsRepository
    private let launchAtLoginRepository: LaunchAtLoginRepository
    private let logService: LogService

    public var toggleMethod: ToggleMethod
    public var modifierFlag: ModifierFlag
    public var longPressSeconds: Double
    public var toolBarPosition: ToolBarPosition
    public var showToggleMethod: Bool
    public var launchAtLogin: Bool
    public let action: (Action) async -> Void

    public init(
        _ appDependencies: AppDependencies,
        action: @escaping (Action) async -> Void = { _ in }
    ) {
        self.userDefaultsRepository = .init(
            appDependencies.userDefaultsClient,
            appDependencies.appStateClient
        )
        self.launchAtLoginRepository = .init(appDependencies.smAppServiceClient)
        self.logService = .init(appDependencies)
        self.toggleMethod = userDefaultsRepository.toggleMethod
        self.modifierFlag = userDefaultsRepository.modifierFlag
        self.longPressSeconds = userDefaultsRepository.longPressSeconds
        self.toolBarPosition = userDefaultsRepository.toolBarPosition
        self.showToggleMethod = userDefaultsRepository.showToggleMethod
        self.launchAtLogin = launchAtLoginRepository.isEnabled
        self.action = action
    }

    public func reduce(_ action: Action) async {
        switch action {
        case let .task(screenName):
            logService.notice(.screenView(name: screenName))

        case let .toggleMethodPickerSelected(toggleMethod):
            self.toggleMethod = toggleMethod
            userDefaultsRepository.toggleMethod = toggleMethod

        case let .modifierFlagPickerSelected(modifierFlag):
            self.modifierFlag = modifierFlag
            userDefaultsRepository.modifierFlag = modifierFlag

        case let .longPressSecondsChanged(longPressSeconds):
            self.longPressSeconds = longPressSeconds

        case .longPressSecondsCommitted:
            userDefaultsRepository.longPressSeconds = longPressSeconds

        case let .toolBarPositionPickerSelected(toolBarPosition):
            self.toolBarPosition = toolBarPosition
            userDefaultsRepository.toolBarPosition = toolBarPosition

        case let .showToggleMethodToggleSwitched(isOn):
            showToggleMethod = isOn
            userDefaultsRepository.showToggleMethod = isOn

        case let .launchAtLoginToggleSwitched(isOn):
            switch launchAtLoginRepository.switchStatus(isOn) {
            case .success:
                launchAtLogin = isOn
            case let .failure(.switchFailed(value)):
                launchAtLogin = value
            }
        }
    }

    public enum Action: Sendable {
        case task(String)
        case toggleMethodPickerSelected(ToggleMethod)
        case modifierFlagPickerSelected(ModifierFlag)
        case longPressSecondsChanged(Double)
        case longPressSecondsCommitted
        case toolBarPositionPickerSelected(ToolBarPosition)
        case showToggleMethodToggleSwitched(Bool)
        case launchAtLoginToggleSwitched(Bool)
    }
}
