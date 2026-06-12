import DataSource

struct ShortcutService {
    private let spiceKeyClient: SpiceKeyClient
    private let userDefaultsRepository: UserDefaultsRepository

    init(_ appDependencies: AppDependencies) {
        self.spiceKeyClient = appDependencies.spiceKeyClient
        self.userDefaultsRepository = .init(
            appDependencies.userDefaultsClient,
            appDependencies.appStateClient
        )
    }

    func setShortcut() {
        spiceKeyClient.setShortcut(
            userDefaultsRepository.toggleMethod,
            userDefaultsRepository.modifierFlag,
            userDefaultsRepository.longPressSeconds
        )
    }
}
