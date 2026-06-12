import AllocatedUnfairLock
import Testing

@testable import DataSource
@testable import Model

struct GeneralSettingsTests {
    @MainActor private func makeStore(
        smAppServiceClient: SMAppServiceClient = .testValue
    ) -> (GeneralSettings, AllocatedUnfairLock<AppState>, TestUserDefaults) {
        let appStateLock = AllocatedUnfairLock<AppState>(initialState: .init())
        let userDefaults = TestUserDefaults()
        let store = GeneralSettings(.testDependencies(
            appStateClient: .testDependency(appStateLock),
            smAppServiceClient: smAppServiceClient,
            userDefaultsClient: userDefaults.client()
        ))
        return (store, appStateLock, userDefaults)
    }

    @MainActor @Test
    func init_reads_repository_values() {
        let (store, _, _) = makeStore()
        #expect(store.toggleMethod == .longPressKey)
        #expect(store.modifierFlag == .control)
        #expect(store.longPressSeconds == 0.5)
        #expect(store.toolBarPosition == .top)
        #expect(store.showToggleMethod == true)
        #expect(store.launchAtLogin == false)
    }

    @MainActor @Test
    func send_toggleMethodPickerSelected_persists_and_streams() async {
        let (store, appStateLock, _) = makeStore()
        await store.send(.toggleMethodPickerSelected(.pressBothSideKeys))
        #expect(store.toggleMethod == .pressBothSideKeys)
        #expect(appStateLock.withLock(\.shortcutSettings.latestValue) != nil)
    }

    @MainActor @Test
    func send_modifierFlagPickerSelected_persists_and_streams() async {
        let (store, appStateLock, _) = makeStore()
        await store.send(.modifierFlagPickerSelected(.command))
        #expect(store.modifierFlag == .command)
        #expect(appStateLock.withLock(\.shortcutSettings.latestValue) != nil)
    }

    @MainActor @Test
    func send_longPressSecondsChanged_defers_persistence_until_committed() async {
        let (store, appStateLock, userDefaults) = makeStore()
        await store.send(.longPressSecondsChanged(1.2))
        let repository = UserDefaultsRepository(userDefaults.client(), .testDependency(appStateLock))
        #expect(repository.longPressSeconds == 0.5)
        await store.send(.longPressSecondsCommitted)
        #expect(repository.longPressSeconds == 1.2)
    }

    @MainActor @Test
    func send_toolBarPositionPickerSelected_persists() async {
        let (store, appStateLock, userDefaults) = makeStore()
        await store.send(.toolBarPositionPickerSelected(.left))
        let repository = UserDefaultsRepository(userDefaults.client(), .testDependency(appStateLock))
        #expect(repository.toolBarPosition == .left)
        #expect(appStateLock.withLock(\.shortcutSettings.latestValue) == nil)
    }

    @MainActor @Test
    func send_launchAtLoginToggleSwitched_success_updates_state() async {
        let enabled = AllocatedUnfairLock<Bool>(initialState: false)
        let client = testDependency(of: SMAppServiceClient.self) {
            $0.isEnabled = { enabled.withLock(\.self) }
            $0.register = { enabled.withLock { $0 = true } }
            $0.unregister = { enabled.withLock { $0 = false } }
        }
        let (store, _, _) = makeStore(smAppServiceClient: client)
        await store.send(.launchAtLoginToggleSwitched(true))
        #expect(store.launchAtLogin == true)
    }

    @MainActor @Test
    func send_launchAtLoginToggleSwitched_failure_reverts_state() async {
        let client = testDependency(of: SMAppServiceClient.self) {
            $0.isEnabled = { false }
            $0.register = { throw LaunchAtLoginRepository.SwitchError.switchFailed(false) }
            $0.unregister = {}
        }
        let (store, _, _) = makeStore(smAppServiceClient: client)
        await store.send(.launchAtLoginToggleSwitched(true))
        #expect(store.launchAtLogin == false)
    }
}
