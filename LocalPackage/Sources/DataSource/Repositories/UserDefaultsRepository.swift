import Foundation
import SpiceKey

public struct UserDefaultsRepository: Sendable {
    private let userDefaultsClient: UserDefaultsClient
    private let appStateClient: AppStateClient

    public var toggleMethod: ToggleMethod {
        get { ToggleMethod(rawValue: userDefaultsClient.integer(.toggleMethod)) ?? .longPressKey }
        nonmutating set {
            userDefaultsClient.set(newValue.rawValue, .toggleMethod)
            appStateClient.withLock { $0.shortcutSettings.send() }
        }
    }

    public var modifierFlag: ModifierFlag {
        get { ModifierFlag(rawValue: userDefaultsClient.integer(.modifierFlag)) ?? .control }
        nonmutating set {
            userDefaultsClient.set(newValue.rawValue, .modifierFlag)
            appStateClient.withLock { $0.shortcutSettings.send() }
        }
    }

    public var longPressSeconds: Double {
        get { userDefaultsClient.double(.longPressSeconds) }
        nonmutating set {
            userDefaultsClient.set(newValue, .longPressSeconds)
            appStateClient.withLock { $0.shortcutSettings.send() }
        }
    }

    public var toolBarPosition: ToolBarPosition {
        get { ToolBarPosition(rawValue: userDefaultsClient.integer(.toolBarPosition)) ?? .top }
        nonmutating set { userDefaultsClient.set(newValue.rawValue, .toolBarPosition) }
    }

    public var showToggleMethod: Bool {
        get { userDefaultsClient.bool(.showToggleMethod) }
        nonmutating set { userDefaultsClient.set(newValue, .showToggleMethod) }
    }

    public var clearAllObjects: Bool {
        get { userDefaultsClient.bool(.clearAllObjects) }
        nonmutating set { userDefaultsClient.set(newValue, .clearAllObjects) }
    }

    public var defaultObjectType: ObjectType {
        get { ObjectType(rawValue: userDefaultsClient.integer(.defaultObjectType)) ?? .pen }
        nonmutating set { userDefaultsClient.set(newValue.rawValue, .defaultObjectType) }
    }

    public var defaultColorIndex: Int {
        get { userDefaultsClient.integer(.defaultColorIndex) }
        nonmutating set { userDefaultsClient.set(newValue, .defaultColorIndex) }
    }

    public var defaultOpacity: CGFloat {
        get { userDefaultsClient.double(.defaultOpacity) }
        nonmutating set { userDefaultsClient.set(newValue, .defaultOpacity) }
    }

    public var defaultLineWidth: CGFloat {
        get { userDefaultsClient.double(.defaultLineWidth) }
        nonmutating set { userDefaultsClient.set(newValue, .defaultLineWidth) }
    }

    public var backgroundColorIndex: Int {
        get { userDefaultsClient.integer(.backgroundColorIndex) }
        nonmutating set { userDefaultsClient.set(newValue, .backgroundColorIndex) }
    }

    public var backgroundOpacity: CGFloat {
        get { userDefaultsClient.double(.backgroundOpacity) }
        nonmutating set { userDefaultsClient.set(newValue, .backgroundOpacity) }
    }

    public init(_ userDefaultsClient: UserDefaultsClient, _ appStateClient: AppStateClient) {
        self.userDefaultsClient = userDefaultsClient
        self.appStateClient = appStateClient
        _ = Self.resetUserDefaultsIfNeeded
        userDefaultsClient.register([
            .toggleMethod: ToggleMethod.longPressKey.rawValue,
            .modifierFlag: ModifierFlag.control.rawValue,
            .longPressSeconds: Double(0.5),
            .toolBarPosition: ToolBarPosition.top.rawValue,
            .showToggleMethod: true,
            .clearAllObjects: false,
            .defaultObjectType: ObjectType.pen.rawValue,
            .defaultColorIndex: Int(0),
            .defaultOpacity: Double(0.8),
            .defaultLineWidth: Double(4.0),
            .backgroundColorIndex: Int(0),
            .backgroundOpacity: Double(0.02),
        ])
        _ = Self.showAllDataIfNeeded
    }

    private static let resetUserDefaultsIfNeeded: Void = {
        guard ProcessInfo.needsResetUserDefaults,
              let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return
        }
        UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
    }()

    private static let showAllDataIfNeeded: Void = {
        guard ProcessInfo.needsShowAllData,
              let bundleIdentifier = Bundle.main.bundleIdentifier,
              let dictionary = UserDefaults.standard.persistentDomain(forName: bundleIdentifier) else {
            return
        }
        for (key, value) in dictionary.sorted(by: { $0.0 < $1.0 }) {
            Swift.print("\(key) => \(value)")
        }
    }()
}
