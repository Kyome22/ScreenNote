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
    var longPressSeconds: Double { get set }
    var toolBarPosition: ToolBarPosition { get set }
    var showToggleMethod: Bool { get set }
    var clearAllObjects: Bool { get set }
    var defaultObjectType: ObjectType { get set }
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
        updateShortcutSubject.eraseToAnyPublisher()
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

    var longPressSeconds: Double {
        get { userDefaults.double(forKey: "longPressSeconds") }
        set {
            userDefaults.set(newValue, forKey: "longPressSeconds")
            updateShortcutSubject.send()
        }
    }

    var toolBarPosition: ToolBarPosition {
        get { ToolBarPosition(rawValue: userDefaults.integer(forKey: "toolBarPosition"))! }
        set { userDefaults.set(newValue.rawValue, forKey: "toolBarPosition") }
    }

    var showToggleMethod: Bool {
        get { userDefaults.bool(forKey: "showToggleMethod") }
        set { userDefaults.set(newValue, forKey: "showToggleMethod") }
    }

    var clearAllObjects: Bool {
        get { userDefaults.bool(forKey: "clearAllObjects") }
        set { userDefaults.set(newValue, forKey: "clearAllObjects") }
    }

    var defaultObjectType: ObjectType {
        get { ObjectType(rawValue: userDefaults.integer(forKey: "defaultObjectType"))! }
        set { userDefaults.set(newValue.rawValue, forKey: "defaultObjectType") }
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
            "longPressSeconds": Double(0.5),
            "toolBarPosition": ToolBarPosition.top.rawValue,
            "showToggleMethod": true,
            "clearAllObjects": false,
            "defaultObjectType": ObjectType.pen.rawValue,
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
            Just(()).eraseToAnyPublisher()
        }

        var toggleMethod: ToggleMethod = .longPressKey
        var modifierFlag: ModifierFlag = .control
        var longPressSeconds: Double = 0.5
        var toolBarPosition: ToolBarPosition = .top
        var showToggleMethod: Bool = true
        var clearAllObjects: Bool = false
        var defaultObjectType: ObjectType = .pen
        var defaultColorIndex: Int = 0
        var defaultOpacity: CGFloat = 0.8
        var defaultLineWidth: CGFloat = 4.0
        var backgroundColorIndex: Int = 0
        var backgroundOpacity: CGFloat = 0.02
    }
}
