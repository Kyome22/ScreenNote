import AppKit
import DataSource
import DeviceModel

public final class AppDelegate: NSObject, NSApplicationDelegate {
    private let appDependencies = AppDependencies.shared

    public func applicationDidFinishLaunching(_ notification: Notification) {
        let appStateClient = appDependencies.appStateClient
        appStateClient.withLock {
            $0.environmentInfo = .init(
                appName: Bundle.main.bundleDisplayName,
                appVersion: Bundle.main.bundleVersion,
                deviceName: DeviceModel.current()?.name ?? "Unknown",
                systemVersion: ProcessInfo.systemVersion
            )
            $0.subscriptionGroupID = Bundle.main.subscriptionGroupID
        }
        let logService = LogService(appDependencies)
        logService.bootstrap()
        let objectService = ObjectService(appDependencies)
        let panelService = PanelService(appDependencies)
        Task {
            let stream = appStateClient.withLock(\.canvasVisibility.stream)
            for await value in stream {
                if value == .visible {
                    objectService.prepareForNewCanvas()
                    panelService.hideTriggerMethodPanel()
                }
                panelService.toggleWorkspacePanel(to: value)
            }
        }
        logService.notice(.launchApp)
        ShortcutService(appDependencies).register()
        Task {
            try? await Task.sleep(for: .seconds(1))
            panelService.showTriggerMethodPanel()
        }
    }

    public func applicationWillTerminate(_ notification: Notification) {
        ShortcutService(appDependencies).unregister()
    }
}
