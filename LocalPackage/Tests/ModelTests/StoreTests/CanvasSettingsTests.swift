import AllocatedUnfairLock
import Testing

@testable import DataSource
@testable import Model

struct CanvasSettingsTests {
    @MainActor private func makeStore() -> (CanvasSettings, UserDefaultsRepository) {
        let appStateLock = AllocatedUnfairLock<AppState>(initialState: .init())
        let userDefaults = TestUserDefaults()
        let store = CanvasSettings(.testDependencies(
            appStateClient: .testDependency(appStateLock),
            userDefaultsClient: userDefaults.client()
        ))
        let repository = UserDefaultsRepository(userDefaults.client(), .testDependency(appStateLock))
        return (store, repository)
    }

    @MainActor @Test
    func init_reads_repository_values() {
        let (store, _) = makeStore()
        #expect(store.clearAllObjects == false)
        #expect(store.defaultObjectType == .pen)
        #expect(store.defaultColorIndex == 0)
        #expect(store.defaultOpacity == 0.8)
        #expect(store.defaultLineWidth == 4.0)
        #expect(store.backgroundColorIndex == 0)
        #expect(store.backgroundOpacity == 0.02)
    }

    @MainActor @Test
    func send_clearAllObjectsToggleSwitched_persists() async {
        let (store, repository) = makeStore()
        await store.send(.clearAllObjectsToggleSwitched(true))
        #expect(store.clearAllObjects == true)
        #expect(repository.clearAllObjects == true)
    }

    @MainActor @Test
    func send_defaultObjectTypePickerSelected_persists() async {
        let (store, repository) = makeStore()
        await store.send(.defaultObjectTypePickerSelected(.lineOval))
        #expect(repository.defaultObjectType == .lineOval)
    }

    @MainActor @Test
    func send_defaultColorSelected_persists() async {
        let (store, repository) = makeStore()
        await store.send(.defaultColorSelected(13))
        #expect(store.defaultColorIndex == 13)
        #expect(repository.defaultColorIndex == 13)
    }

    @MainActor @Test
    func send_slider_changes_defer_persistence_until_committed() async {
        let (store, repository) = makeStore()
        await store.send(.defaultOpacityChanged(0.4))
        await store.send(.defaultLineWidthChanged(8.0))
        await store.send(.backgroundOpacityChanged(0.5))
        #expect(repository.defaultOpacity == 0.8)
        #expect(repository.defaultLineWidth == 4.0)
        #expect(repository.backgroundOpacity == 0.02)
        await store.send(.defaultOpacityCommitted)
        await store.send(.defaultLineWidthCommitted)
        await store.send(.backgroundOpacityCommitted)
        #expect(repository.defaultOpacity == 0.4)
        #expect(repository.defaultLineWidth == 8.0)
        #expect(repository.backgroundOpacity == 0.5)
    }

    @MainActor @Test
    func send_backgroundColorSelected_persists() async {
        let (store, repository) = makeStore()
        await store.send(.backgroundColorSelected(1))
        #expect(repository.backgroundColorIndex == 1)
    }
}
