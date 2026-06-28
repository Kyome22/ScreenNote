import AllocatedUnfairLock
import SpiceKey
import Testing

@testable import DataSource
@testable import Model

struct ShortcutServiceTests {
    @Test func register_longPressKey_registers_spiceKey_and_stores_it() {
        let appState = AllocatedUnfairLock<AppState>(initialState: .init())
        let registerCount = AllocatedUnfairLock<Int>(initialState: 0)
        let service = ShortcutService(.testDependencies(
            appStateClient: .testDependency(appState),
            spiceKeyClient: testDependency(of: SpiceKeyClient.self) {
                $0.register = { _ in registerCount.withLock { $0 += 1 } }
            },
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.double = { key in key == .longPressDuration ? 0.5 : 0 }
            }
        ))
        service.register()
        #expect(registerCount.withLock(\.self) == 1)
        #expect(appState.withLock(\.spiceKey) != nil)
    }

    @Test func register_pressBothSideKeys_registers_spiceKey() {
        let appState = AllocatedUnfairLock<AppState>(initialState: .init())
        let registerCount = AllocatedUnfairLock<Int>(initialState: 0)
        let service = ShortcutService(.testDependencies(
            appStateClient: .testDependency(appState),
            spiceKeyClient: testDependency(of: SpiceKeyClient.self) {
                $0.register = { _ in registerCount.withLock { $0 += 1 } }
            },
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.integer = { key in key == .triggerMethod ? TriggerMethod.pressBothSideKeys.rawValue : 0 }
            }
        ))
        service.register()
        #expect(registerCount.withLock(\.self) == 1)
        #expect(appState.withLock(\.spiceKey)?.isBothSide == true)
    }

    @Test func register_again_unregisters_previous_spiceKey() {
        let appState = AllocatedUnfairLock<AppState>(initialState: .init())
        let registerCount = AllocatedUnfairLock<Int>(initialState: 0)
        let unregisterCount = AllocatedUnfairLock<Int>(initialState: 0)
        let service = ShortcutService(.testDependencies(
            appStateClient: .testDependency(appState),
            spiceKeyClient: testDependency(of: SpiceKeyClient.self) {
                $0.register = { _ in registerCount.withLock { $0 += 1 } }
                $0.unregister = { _ in unregisterCount.withLock { $0 += 1 } }
            },
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.double = { key in key == .longPressDuration ? 0.5 : 0 }
            }
        ))
        service.register()
        service.register()
        #expect(registerCount.withLock(\.self) == 2)
        #expect(unregisterCount.withLock(\.self) == 1)
    }

    @Test func unregister_unregisters_stored_spiceKey() {
        let appState = AllocatedUnfairLock<AppState>(initialState: .init())
        let unregisterCount = AllocatedUnfairLock<Int>(initialState: 0)
        let service = ShortcutService(.testDependencies(
            appStateClient: .testDependency(appState),
            spiceKeyClient: testDependency(of: SpiceKeyClient.self) {
                $0.unregister = { _ in unregisterCount.withLock { $0 += 1 } }
            },
            userDefaultsClient: testDependency(of: UserDefaultsClient.self) {
                $0.double = { key in key == .longPressDuration ? 0.5 : 0 }
            }
        ))
        service.register()
        service.unregister()
        #expect(unregisterCount.withLock(\.self) == 1)
    }

    @Test func unregister_without_registration_does_nothing() {
        let unregisterCount = AllocatedUnfairLock<Int>(initialState: 0)
        let service = ShortcutService(.testDependencies(
            spiceKeyClient: testDependency(of: SpiceKeyClient.self) {
                $0.unregister = { _ in unregisterCount.withLock { $0 += 1 } }
            }
        ))
        service.unregister()
        #expect(unregisterCount.withLock(\.self) == 0)
    }
}
