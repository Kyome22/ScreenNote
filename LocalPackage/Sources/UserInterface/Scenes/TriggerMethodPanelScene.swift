import DataSource
import SwiftUI
import WindowSceneKit

public struct TriggerMethodPanelScene: Scene {
    @Environment(\.appDependencies) private var appDependencies
    @WindowState(.triggerMethodPanel) private var isPresented = false

    public init() {}

    public var body: some Scene {
        WindowScene(isPresented: $isPresented, key: .triggerMethodPanel) { _ in
            TriggerMethodPanel(appDependencies) { triggerMethod, modifierFlag in
                TriggerMethodView(triggerMethod: triggerMethod, modifierFlag: modifierFlag )
            }
        }
    }
}
