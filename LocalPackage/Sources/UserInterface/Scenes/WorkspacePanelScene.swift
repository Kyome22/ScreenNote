import DataSource
import SwiftUI
import WindowSceneKit

public struct WorkspacePanelScene: Scene {
    @Environment(\.appDependencies) private var appDependencies
    @WindowState(.workspacePanel) private var isPresented = false

    public init() {}

    public var body: some Scene {
        WindowScene(isPresented: $isPresented, key: .workspacePanel) { _ in
            WorkspacePanel(appDependencies) {
                WorkspaceView(store: .init(appDependencies))
            }
        }
    }
}
