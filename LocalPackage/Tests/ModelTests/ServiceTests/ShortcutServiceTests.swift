import AllocatedUnfairLock
import SpiceKey
import Testing

@testable import DataSource
@testable import Model

struct ShortcutServiceTests {
    @Test func setShortcut_passes_repository_values_to_client() {
        let recorded = AllocatedUnfairLock<[String]>(initialState: [])
        let userDefaults = TestUserDefaults()
        let appStateLock = AllocatedUnfairLock<AppState>(initialState: .init())
        let repository = UserDefaultsRepository(userDefaults.client(), .testDependency(appStateLock))
        repository.toggleMethod = .pressBothSideKeys
        repository.longPressSeconds = 1.0
        let service = ShortcutService(.testDependencies(
            appStateClient: .testDependency(appStateLock),
            spiceKeyClient: testDependency(of: SpiceKeyClient.self) {
                $0.setShortcut = { toggleMethod, modifierFlag, longPressSeconds in
                    recorded.withLock {
                        $0.append("\(toggleMethod.rawValue)|\(modifierFlag.rawValue)|\(longPressSeconds)")
                    }
                }
            },
            userDefaultsClient: userDefaults.client()
        ))
        service.setShortcut()
        #expect(recorded.withLock(\.self) == ["1|0|1.0"])
    }
}
