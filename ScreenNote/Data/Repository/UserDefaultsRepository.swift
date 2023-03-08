/*
  UserDefaultsRepository.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import Combine
import Foundation
import SpiceKey

fileprivate let RESET_USER_DEFAULTS = false

protocol UserDefaultsRepository: AnyObject {
    var updateShortcutPublisher: AnyPublisher<Void, Never> { get }

    var toggleMethod: ToggleMethod { get set }
    var modifierFlag: ModifierFlag { get set }
    var toolBarPosition: ToolBarPosition { get set }
    var clearAllObjects: Bool { get set }
    var defaultColorIndex: Int { get set }
    var defaultOpacity: CGFloat { get set }
    var defaultLineWidth: CGFloat { get set }
    var backgroundColorIndex: Int { get set }
    var backgroundOpacity: CGFloat { get set }
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
            updateShortcutSubject.send()
        }
    }
    var modifierFlag: ModifierFlag {
        get { ModifierFlag(rawValue: userDefaults.integer(forKey: "modifierFlag"))! }
        set {
            userDefaults.set(newValue.rawValue, forKey: "modifierFlag")
            updateShortcutSubject.send()
        }
    }
    var toolBarPosition: ToolBarPosition {
        get { ToolBarPosition(rawValue: userDefaults.integer(forKey: "toolBarPosition"))! }
        set { userDefaults.set(newValue.rawValue, forKey: "toolBarPosition") }
    }

    var clearAllObjects: Bool {
        get { userDefaults.bool(forKey: "clearAllObjects") }
        set { userDefaults.set(newValue, forKey: "clearAllObjects") }
    }

    var defaultColorIndex: Int {
        get { userDefaults.integer(forKey: "defaultColorIndex") }
        set { userDefaults.set(newValue, forKey: "defaultColorIndex") }
    }

    var defaultOpacity: CGFloat {
        get { userDefaults.double(forKey: "defaultOpacity") }
        set { userDefaults.set(newValue, forKey: "defaultOpacity") }
    }

    var defaultLineWidth: CGFloat {
        get { userDefaults.double(forKey: "defaultLineWidth") }
        set { userDefaults.set(newValue, forKey: "defaultLineWidth") }
    }

    var backgroundColorIndex: Int {
        get { userDefaults.integer(forKey: "backgroundColorIndex") }
        set { userDefaults.set(newValue, forKey: "backgroundColorIndex") }
    }

    var backgroundOpacity: CGFloat  {
        get { userDefaults.double(forKey: "backgroundOpacity") }
        set { userDefaults.set(newValue, forKey: "backgroundOpacity") }
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
            "toolBarPosition": ToolBarPosition.top.rawValue,
            "clearAllObjects": false,
            "defaultColorIndex": Int(0),
            "defaultOpacity": Double(0.8),
            "defaultLineWidth": Double(4.0),
            "backgroundColorIndex": Int(0),
            "backgroundOpacity": Double(0.02)
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
        var clearAllObjects: Bool = false
        var defaultColorIndex: Int = 0
        var defaultOpacity: CGFloat = 0.8
        var defaultLineWidth: CGFloat = 4.0
        var backgroundColorIndex: Int = 0
        var backgroundOpacity: CGFloat = 0.02
    }
}
