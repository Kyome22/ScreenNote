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
        // MIGRATION: Phase 3 wires ShortcutService and the shortcutSettings/shortcutCommand observers.
        logService.notice(.launchApp)
    }
}
