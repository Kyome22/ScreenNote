import Foundation

public struct UserDefaultsClient: DependencyClient {
    var object: @Sendable (String) -> Any?
    var bool: @Sendable (String) -> Bool
    var integer: @Sendable (String) -> Int
    var double: @Sendable (String) -> Double
    var string: @Sendable (String) -> String?
    var data: @Sendable (String) -> Data?
    var set: @Sendable (Any?, String) -> Void
    var removeObject: @Sendable (String) -> Void
    var register: @Sendable ([String: Any]) -> Void
    var removePersistentDomain: @Sendable (String) -> Void
    var persistentDomain: @Sendable (String) -> [String: Any]?

    public static let liveValue = Self(
        object: { UserDefaults.standard.object(forKey: $0) },
        bool: { UserDefaults.standard.bool(forKey: $0) },
        integer: { UserDefaults.standard.integer(forKey: $0) },
        double: { UserDefaults.standard.double(forKey: $0) },
        string: { UserDefaults.standard.string(forKey: $0) },
        data: { UserDefaults.standard.data(forKey: $0) },
        set: { UserDefaults.standard.set($0, forKey: $1) },
        removeObject: { UserDefaults.standard.removeObject(forKey: $0) },
        register: { UserDefaults.standard.register(defaults: $0) },
        removePersistentDomain: { UserDefaults.standard.removePersistentDomain(forName: $0) },
        persistentDomain: { UserDefaults.standard.persistentDomain(forName: $0) }
    )

    public static let testValue = Self(
        object: { _ in nil },
        bool: { _ in false },
        integer: { _ in 0 },
        double: { _ in 0 },
        string: { _ in nil },
        data: { _ in nil },
        set: { _, _ in },
        removeObject: { _ in },
        register: { _ in },
        removePersistentDomain: { _ in },
        persistentDomain: { _ in nil }
    )
}

extension UserDefaults: @retroactive @unchecked Sendable {}
