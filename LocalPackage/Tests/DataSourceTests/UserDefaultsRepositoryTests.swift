import AllocatedUnfairLock
import Foundation
import SpiceKey
import Testing

@testable import DataSource

struct UserDefaultsRepositoryTests {
    private func makeRepository() -> (UserDefaultsRepository, AllocatedUnfairLock<AppState>) {
        let appStateLock = AllocatedUnfairLock<AppState>(initialState: .init())
        let repository = UserDefaultsRepository(
            TestUserDefaults().client(),
            AppStateClient.testDependency(appStateLock)
        )
        return (repository, appStateLock)
    }

    @Test func get_returns_registered_defaults() {
        let (repository, _) = makeRepository()
        #expect(repository.toggleMethod == .longPressKey)
        #expect(repository.modifierFlag == .control)
        #expect(repository.longPressSeconds == 0.5)
        #expect(repository.toolBarPosition == .top)
        #expect(repository.showToggleMethod == true)
        #expect(repository.clearAllObjects == false)
        #expect(repository.defaultObjectType == .pen)
        #expect(repository.defaultColorIndex == 0)
        #expect(repository.defaultOpacity == 0.8)
        #expect(repository.defaultLineWidth == 4.0)
        #expect(repository.backgroundColorIndex == 0)
        #expect(repository.backgroundOpacity == 0.02)
    }

    @Test func set_toggleMethod_persists_and_streams_shortcut_settings() {
        let (repository, appStateLock) = makeRepository()
        repository.toggleMethod = .pressBothSideKeys
        #expect(repository.toggleMethod == .pressBothSideKeys)
        #expect(appStateLock.withLock(\.shortcutSettings.latestValue) != nil)
    }

    @Test func set_modifierFlag_persists_and_streams_shortcut_settings() {
        let (repository, appStateLock) = makeRepository()
        repository.modifierFlag = .option
        #expect(repository.modifierFlag == .option)
        #expect(appStateLock.withLock(\.shortcutSettings.latestValue) != nil)
    }

    @Test func set_longPressSeconds_persists_and_streams_shortcut_settings() {
        let (repository, appStateLock) = makeRepository()
        repository.longPressSeconds = 1.5
        #expect(repository.longPressSeconds == 1.5)
        #expect(appStateLock.withLock(\.shortcutSettings.latestValue) != nil)
    }

    @Test func set_plain_settings_round_trip() {
        let (repository, appStateLock) = makeRepository()
        repository.toolBarPosition = .left
        repository.showToggleMethod = false
        repository.clearAllObjects = true
        repository.defaultObjectType = .arrow
        repository.defaultColorIndex = 9
        repository.defaultOpacity = 0.5
        repository.defaultLineWidth = 10.0
        repository.backgroundColorIndex = 1
        repository.backgroundOpacity = 0.25
        #expect(repository.toolBarPosition == .left)
        #expect(repository.showToggleMethod == false)
        #expect(repository.clearAllObjects == true)
        #expect(repository.defaultObjectType == .arrow)
        #expect(repository.defaultColorIndex == 9)
        #expect(repository.defaultOpacity == 0.5)
        #expect(repository.defaultLineWidth == 10.0)
        #expect(repository.backgroundColorIndex == 1)
        #expect(repository.backgroundOpacity == 0.25)
        #expect(appStateLock.withLock(\.shortcutSettings.latestValue) == nil)
    }

    @Test func userDefaults_keys_match_legacy_strings() {
        #expect(String.backgroundColorIndex == "backgroundColorIndex")
        #expect(String.backgroundOpacity == "backgroundOpacity")
        #expect(String.clearAllObjects == "clearAllObjects")
        #expect(String.defaultColorIndex == "defaultColorIndex")
        #expect(String.defaultLineWidth == "defaultLineWidth")
        #expect(String.defaultObjectType == "defaultObjectType")
        #expect(String.defaultOpacity == "defaultOpacity")
        #expect(String.longPressSeconds == "longPressSeconds")
        #expect(String.modifierFlag == "modifierFlag")
        #expect(String.showToggleMethod == "showToggleMethod")
        #expect(String.toggleMethod == "toggleMethod")
        #expect(String.toolBarPosition == "toolBarPosition")
    }

    @Test func legacy_raw_values_keep_meaning() {
        #expect(ToggleMethod.longPressKey.rawValue == 0)
        #expect(ToggleMethod.pressBothSideKeys.rawValue == 1)
        #expect(ToolBarPosition.top.rawValue == 0)
        #expect(ObjectType.pen.rawValue == 2)
        #expect(ModifierFlag.control.rawValue == 0)
    }
}
