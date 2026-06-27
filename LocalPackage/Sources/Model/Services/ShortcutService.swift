import DataSource
import SpiceKey

struct ShortcutService {
    private let appStateClient: AppStateClient
    private let spiceKeyClient: SpiceKeyClient
    private let userDefaultsRepository: UserDefaultsRepository

    init(_ appDependencies: AppDependencies) {
        appStateClient = appDependencies.appStateClient
        spiceKeyClient = appDependencies.spiceKeyClient
        userDefaultsRepository = .init(appDependencies.userDefaultsClient)
    }

    func register() {
        let triggerMethod = userDefaultsRepository.triggerMethod
        let modifierFlag = userDefaultsRepository.modifierFlag
        let longPressDuration = userDefaultsRepository.longPressDuration
        let newSpiceKey = switch triggerMethod {
        case .longPressKey:
            SpiceKey(modifierFlag.flags, interval: longPressDuration, modifierKeysLongPressHandler: {
                if let canvasVisibility = appStateClient.withLock(\.canvasVisibility.latestValue) {
                    appStateClient.send(\.canvasVisibility, canvasVisibility.toggled)
                } else {
                    appStateClient.send(\.canvasVisibility, .visible)
                }
            })
        case .pressBothSideKeys:
            SpiceKey(modifierFlag, bothModifierKeysPressHandler: {
                if let canvasVisibility = appStateClient.withLock(\.canvasVisibility.latestValue) {
                    appStateClient.send(\.canvasVisibility, canvasVisibility.toggled)
                } else {
                    appStateClient.send(\.canvasVisibility, .visible)
                }
            })
        }
        guard let newSpiceKey else { return }
        if let oldSpiceKey = appStateClient.withLock(\.spiceKey) {
            spiceKeyClient.unregister(oldSpiceKey)
        }
        spiceKeyClient.register(newSpiceKey)
        appStateClient.withLock { $0.spiceKey = newSpiceKey }
    }

    func unregister() {
        guard let spiceKey = appStateClient.withLock(\.spiceKey) else { return }
        spiceKeyClient.unregister(spiceKey)
    }
}
