import Foundation
import SpiceKey

public struct UserDefaultsRepository: Sendable {
    private let userDefaultsClient: UserDefaultsClient

    public var triggerMethod: TriggerMethod {
        get { TriggerMethod(rawValue: userDefaultsClient.integer(.triggerMethod)) ?? .longPressKey }
        nonmutating set { userDefaultsClient.set(newValue.rawValue, .triggerMethod) }
    }

    public var modifierFlag: ModifierFlag {
        get { ModifierFlag(rawValue: userDefaultsClient.integer(.modifierFlag)) ?? .control }
        nonmutating set { userDefaultsClient.set(newValue.rawValue, .modifierFlag) }
    }

    public var longPressDuration: Double {
        get { userDefaultsClient.double(.longPressDuration) }
        nonmutating set { userDefaultsClient.set(newValue, .longPressDuration) }
    }

    public var toolBarPosition: ToolBarPosition {
        get { ToolBarPosition(rawValue: userDefaultsClient.integer(.toolBarPosition)) ?? .top }
        nonmutating set { userDefaultsClient.set(newValue.rawValue, .toolBarPosition) }
    }

    public var showsTriggerMethod: Bool {
        get { userDefaultsClient.bool(.showsTriggerMethod) }
        nonmutating set { userDefaultsClient.set(newValue, .showsTriggerMethod) }
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

    public init(_ userDefaultsClient: UserDefaultsClient) {
        self.userDefaultsClient = userDefaultsClient
        if ProcessInfo.needsResetUserDefaults {
            userDefaultsClient.removePersistentDomain(Bundle.main.bundleIdentifier!)
        }
        userDefaultsClient.register([
            .triggerMethod: TriggerMethod.longPressKey.rawValue,
            .modifierFlag: ModifierFlag.control.rawValue,
            .longPressDuration: Double(0.5),
            .toolBarPosition: ToolBarPosition.top.rawValue,
            .showsTriggerMethod: true,
            .clearAllObjects: false,
            .defaultObjectType: ObjectType.pen.rawValue,
            .defaultColorIndex: Int(0),
            .defaultOpacity: Double(0.8),
            .defaultLineWidth: Double(4.0),
            .backgroundColorIndex: Int(0),
            .backgroundOpacity: Double(0.02),
        ])
        if ProcessInfo.needsShowAllData {
            showAllData()
        }
        migration()
    }

    private func migration() {
        if userDefaultsClient.object(.toggleMethod) != nil,
           let triggerMethod = TriggerMethod(rawValue: userDefaultsClient.integer(.toggleMethod)) {
            self.triggerMethod = triggerMethod
            userDefaultsClient.removeObject(.toggleMethod)
        }
        if userDefaultsClient.object(.showToggleMethod) != nil {
            showsTriggerMethod = userDefaultsClient.bool(.showToggleMethod)
            userDefaultsClient.removeObject(.showToggleMethod)
        }
        if userDefaultsClient.object(.longPressSeconds) != nil {
            longPressDuration = userDefaultsClient.double(.longPressSeconds)
            userDefaultsClient.removeObject(.longPressSeconds)
        }
    }

    private func showAllData() {
        guard let dict = userDefaultsClient.persistentDomain(Bundle.main.bundleIdentifier!) else {
            return
        }
        for (key, value) in dict.sorted(by: { $0.0 < $1.0 }) {
            Swift.print("\(key) => \(value)")
        }
    }
}
