import SwiftUI

public struct SettingsScene: Scene {
    public init() {}

    public var body: some Scene {
        Settings {
            SettingsView()
        }
        .windowResizability(.contentSize)
    }
}
