import AppKit
import Model

@MainActor
public final class ScreenNoteAppDelegate: NSObject, NSApplicationDelegate {
    private let appDelegate = AppDelegate()
    private let workspacePanelBridge = WorkspacePanelBridge()

    public func applicationDidFinishLaunching(_ notification: Notification) {
        appDelegate.applicationDidFinishLaunching(notification)
        workspacePanelBridge.start()
    }

    public func applicationWillTerminate(_ notification: Notification) {
        workspacePanelBridge.fadeOutShortcutPanel()
    }
}
