import AllocatedUnfairLock
import SpiceKey
import Testing

@testable import DataSource
@testable import Model

struct GeneralSettingsTests {
    @MainActor @Test
    func send_triggerMethodPickerSelected_persists_and_registers_shortcut() async {
        let appState = AllocatedUnfairLock<AppState>(initialState: .init())
        let triggerMethod = AllocatedUnfairLock<Int>(initialState: TriggerMethod.longPressKey.rawValue)
        let sut = GeneralSettings(.testDependencies(
            appStateClient: .testDependency(appState),
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.integer = { key in key == .triggerMethod ? triggerMethod.withLock(\.self) : 0 }
                $0.set = { value, key in
                    if key == .triggerMethod, let rawValue = value as? Int {
                        triggerMethod.withLock { $0 = rawValue }
                    }
                }
            }
        ))
        await sut.send(.triggerMethodPickerSelected(.pressBothSideKeys))
        #expect(sut.triggerMethod == .pressBothSideKeys)
        #expect(triggerMethod.withLock(\.self) == TriggerMethod.pressBothSideKeys.rawValue)
        #expect(appState.withLock(\.spiceKey)?.isBothSide == true)
    }

    @MainActor @Test
    func send_modifierFlagPickerSelected_persists_and_registers_shortcut() async {
        let appState = AllocatedUnfairLock<AppState>(initialState: .init())
        let modifierFlag = AllocatedUnfairLock<Int?>(initialState: nil)
        let sut = GeneralSettings(.testDependencies(
            appStateClient: .testDependency(appState),
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.double = { _ in 0.5 }
                $0.set = { value, key in
                    let rawValue = value as? Int
                    if key == .modifierFlag { modifierFlag.withLock { $0 = rawValue } }
                }
            }
        ))
        await sut.send(.modifierFlagPickerSelected(.command))
        #expect(sut.modifierFlag == .command)
        #expect(modifierFlag.withLock(\.self) == ModifierFlag.command.rawValue)
        #expect(appState.withLock(\.spiceKey) != nil)
    }

    @MainActor @Test
    func send_longPressDurationChanged_persists_only_when_editing_ends() async {
        let appState = AllocatedUnfairLock<AppState>(initialState: .init())
        let longPressDuration = AllocatedUnfairLock<Double>(initialState: 0.5)
        let sut = GeneralSettings(.testDependencies(
            appStateClient: .testDependency(appState),
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.double = { key in key == .longPressDuration ? longPressDuration.withLock(\.self) : 0 }
                $0.set = { value, key in
                    if key == .longPressDuration, let rawValue = value as? Double {
                        longPressDuration.withLock { $0 = rawValue }
                    }
                }
            }
        ))
        sut.longPressDuration = 1.2
        await sut.send(.longPressDurationChanged(true))
        #expect(longPressDuration.withLock(\.self) == 0.5)
        await sut.send(.longPressDurationChanged(false))
        #expect(longPressDuration.withLock(\.self) == 1.2)
    }

    @MainActor @Test
    func send_toolBarPositionPickerSelected_persists_without_registering_shortcut() async {
        let appState = AllocatedUnfairLock<AppState>(initialState: .init())
        let toolBarPosition = AllocatedUnfairLock<Int?>(initialState: nil)
        let sut = GeneralSettings(.testDependencies(
            appStateClient: .testDependency(appState),
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.set = { value, key in
                    let rawValue = value as? Int
                    if key == .toolBarPosition { toolBarPosition.withLock { $0 = rawValue } }
                }
            }
        ))
        await sut.send(.toolBarPositionPickerSelected(.left))
        #expect(sut.toolBarPosition == .left)
        #expect(toolBarPosition.withLock(\.self) == ToolBarPosition.left.rawValue)
        #expect(appState.withLock(\.spiceKey) == nil)
    }

    @MainActor @Test
    func send_showTriggerMethodToggleSwitched_persists() async {
        let showsTriggerMethod = AllocatedUnfairLock<Bool?>(initialState: nil)
        let sut = GeneralSettings(.testDependencies(
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.set = { value, key in
                    let rawValue = value as? Bool
                    if key == .showsTriggerMethod { showsTriggerMethod.withLock { $0 = rawValue } }
                }
            }
        ))
        await sut.send(.showTriggerMethodToggleSwitched(false))
        #expect(sut.showsTriggerMethod == false)
        #expect(showsTriggerMethod.withLock(\.self) == false)
    }

    @MainActor @Test
    func send_launchAtLoginToggleSwitched_success_updates_state() async {
        let enabled = AllocatedUnfairLock<Bool>(initialState: false)
        let sut = GeneralSettings(.testDependencies(
            smAppServiceClient: testDependency(of: SMAppServiceClient.self) {
                $0.isEnabled = { enabled.withLock(\.self) }
                $0.register = { enabled.withLock { $0 = true } }
                $0.unregister = { enabled.withLock { $0 = false } }
            }
        ))
        await sut.send(.launchAtLoginToggleSwitched(true))
        #expect(sut.launchesAtLogin == true)
    }

    @MainActor @Test
    func send_launchAtLoginToggleSwitched_failure_reverts_state() async {
        let sut = GeneralSettings(.testDependencies(
            smAppServiceClient: testDependency(of: SMAppServiceClient.self) {
                $0.isEnabled = { false }
                $0.register = { throw LaunchAtLoginRepository.SwitchError.switchFailed(false) }
                $0.unregister = {}
            }
        ))
        await sut.send(.launchAtLoginToggleSwitched(true))
        #expect(sut.launchesAtLogin == false)
    }
}
