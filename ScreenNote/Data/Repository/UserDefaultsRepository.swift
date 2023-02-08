/*
  UserDefaultsRepository.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import Foundation
import Combine
import SpiceKey

fileprivate let RESET_USER_DEFAULTS = false

protocol UserDefaultsRepository: AnyObject {
    var updateShortcutPublisher: AnyPublisher<Void, Never> { get }

    var toggleMethod: ToggleMethod { get set }
    var modifierFlag: ModifierFlag { get set }
    var toolBarPosition: ToolBarPosition { get set }
}

final class UserDefaultsRepositoryImpl: UserDefaultsRepository {
    private let userDefaults: UserDefaults

    private let updateShortcutSubject = PassthroughSubject<Void, Never>()
    var updateShortcutPublisher: AnyPublisher<Void, Never> {
        return updateShortcutSubject.eraseToAnyPublisher()
    }

    var toggleMethod: ToggleMethod {
        get { ToggleMethod(rawValue: userDefaults.integer(forKey: "toggleMethod"))! }
        set {
            userDefaults.set(newValue.rawValue, forKey: "toggleMethod")
            updateShortcutSubject.send(())
        }
    }
    var modifierFlag: ModifierFlag {
        get { ModifierFlag(rawValue: userDefaults.integer(forKey: "modifierFlag"))! }
        set {
            userDefaults.set(newValue.rawValue, forKey: "modifierFlag")
            updateShortcutSubject.send(())
        }
    }
    var toolBarPosition: ToolBarPosition {
        get { ToolBarPosition(rawValue: userDefaults.integer(forKey: "toolBarPosition"))! }
        set { userDefaults.set(newValue.rawValue, forKey: "toolBarPosition") }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
#if DEBUG
        if RESET_USER_DEFAULTS {
            self.userDefaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        }
#endif
        self.userDefaults.register(defaults: [
            "toggleMethod": ToggleMethod.longPressKey.rawValue,
            "modifierFlag": ModifierFlag.control.rawValue,
            "toolBarPosition": ToolBarPosition.top.rawValue
        ])
#if DEBUG
        showAllData()
#endif
    }

    private func showAllData() {
        if let dict = userDefaults.persistentDomain(forName: Bundle.main.bundleIdentifier!) {
            for (key, value) in dict.sorted(by: { $0.0 < $1.0 }) {
                Swift.print("\(key) => \(value)")
            }
        }
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class UserDefaultsRepositoryMock: UserDefaultsRepository {
        var updateShortcutPublisher: AnyPublisher<Void, Never> {
            return Just(()).eraseToAnyPublisher()
        }

        var toggleMethod: ToggleMethod = .longPressKey
        var modifierFlag: ModifierFlag = .control
        var toolBarPosition: ToolBarPosition = .top
    }
}
