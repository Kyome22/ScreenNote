import Model
import SwiftUI
import UserInterface

@main
struct ScreenNoteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarScene()
        SettingsScene()
        TriggerMethodPanelScene()
        WorkspacePanelScene()
    }
}
