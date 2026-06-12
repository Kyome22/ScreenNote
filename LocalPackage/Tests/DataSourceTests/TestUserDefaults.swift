import Foundation
@testable import DataSource

final class TestUserDefaults: @unchecked Sendable {
    private let lock = NSLock()
    private var storage = [String: Any]()

    private func value(_ key: String) -> Any? {
        lock.lock()
        defer { lock.unlock() }
        return storage[key]
    }

    private func set(_ value: Any?, _ key: String) {
        lock.lock()
        defer { lock.unlock() }
        storage[key] = value
    }

    private func register(_ defaults: [String: Any]) {
        lock.lock()
        defer { lock.unlock() }
        for (key, value) in defaults where storage[key] == nil {
            storage[key] = value
        }
    }

    private func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        storage.removeAll()
    }

    private func all() -> [String: Any] {
        lock.lock()
        defer { lock.unlock() }
        return storage
    }

    func client() -> UserDefaultsClient {
        testDependency(of: UserDefaultsClient.self) { client in
            client.bool = { (self.value($0) as? Bool) ?? false }
            client.integer = { (self.value($0) as? Int) ?? 0 }
            client.double = {
                let value = self.value($0)
                return (value as? Double) ?? (value as? CGFloat).map(Double.init) ?? 0
            }
            client.string = { self.value($0) as? String }
            client.data = { self.value($0) as? Data }
            client.set = { self.set($0, $1) }
            client.removeObject = { self.set(nil, $0) }
            client.register = { self.register($0) }
            client.removePersistentDomain = { _ in self.removeAll() }
            client.persistentDomain = { _ in self.all() }
        }
    }
}
