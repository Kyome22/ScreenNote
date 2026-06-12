import SwiftUI
import UserInterface

@main
struct ScreenNoteApp: App {
    @NSApplicationDelegateAdaptor(ScreenNoteAppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarScene()
        SettingsScene()
    }
}
