import AllocatedUnfairLock
import Testing

@testable import DataSource

struct UserDefaultsRepositoryTests {
    @Test func migration_copies_legacy_values_to_current_keys_and_removes_legacy() {
        let triggerMethod = AllocatedUnfairLock<Int?>(initialState: nil)
        let showsTriggerMethod = AllocatedUnfairLock<Bool?>(initialState: nil)
        let longPressDuration = AllocatedUnfairLock<Double?>(initialState: nil)
        let removedKeys = AllocatedUnfairLock<[String]>(initialState: [])
        _ = UserDefaultsRepository(testDependency(of: UserDefaultsClient.self) {
            $0.object = { key in
                switch key {
                case .toggleMethod, .showToggleMethod, .longPressSeconds:
                    return true
                default:
                    return nil
                }
            }
            $0.integer = { key in key == .toggleMethod ? TriggerMethod.pressBothSideKeys.rawValue : 0 }
            $0.bool = { _ in false }
            $0.double = { key in key == .longPressSeconds ? 1.2 : 0 }
            $0.set = { value, key in
                switch key {
                case .triggerMethod:
                    let rawValue = value as? Int
                    triggerMethod.withLock { $0 = rawValue }
                case .showsTriggerMethod:
                    let rawValue = value as? Bool
                    showsTriggerMethod.withLock { $0 = rawValue }
                case .longPressDuration:
                    let rawValue = value as? Double
                    longPressDuration.withLock { $0 = rawValue }
                default:
                    break
                }
            }
            $0.removeObject = { key in removedKeys.withLock { $0.append(key) } }
        })
        #expect(triggerMethod.withLock(\.self) == TriggerMethod.pressBothSideKeys.rawValue)
        #expect(showsTriggerMethod.withLock(\.self) == false)
        #expect(longPressDuration.withLock(\.self) == 1.2)
        #expect(removedKeys.withLock(\.self).sorted() == [String.longPressSeconds, .showToggleMethod, .toggleMethod])
    }

    @Test func migration_is_skipped_when_no_legacy_keys_present() {
        let setKeys = AllocatedUnfairLock<[String]>(initialState: [])
        let removedKeys = AllocatedUnfairLock<[String]>(initialState: [])
        _ = UserDefaultsRepository(testDependency(of: UserDefaultsClient.self) {
            $0.set = { _, key in setKeys.withLock { $0.append(key) } }
            $0.removeObject = { key in removedKeys.withLock { $0.append(key) } }
        })
        #expect(setKeys.withLock(\.self).isEmpty)
        #expect(removedKeys.withLock(\.self).isEmpty)
    }
}
