import AppKit
import DataSource

public final class AppDelegate: NSObject, NSApplicationDelegate {
    private let appDependencies = AppDependencies.shared

    public func applicationDidFinishLaunching(_ notification: Notification) {
        appDependencies.appStateClient.withLock {
            $0.name = Bundle.main.bundleDisplayName
            $0.version = Bundle.main.bundleVersion
        }
        let logService = LogService(appDependencies)
        logService.bootstrap()

        let appStateClient = appDependencies.appStateClient
        let spiceKeyClient = appDependencies.spiceKeyClient
        let shortcutService = ShortcutService(appDependencies)
        let objectService = ObjectService(appDependencies)

        objectService.resetHistory()
        shortcutService.setShortcut()

        Task {
            await withTaskGroup { group in
                group.addTask {
                    for await _ in spiceKeyClient.toggles() {
                        appStateClient.withLock { $0.shortcutCommand.send() }
                    }
                }
                group.addTask {
                    let stream = appStateClient.withLock(\.shortcutSettings.stream)
                    for await _ in stream {
                        shortcutService.setShortcut()
                    }
                }
            }
        }

        logService.notice(.launchApp)
    }
}
