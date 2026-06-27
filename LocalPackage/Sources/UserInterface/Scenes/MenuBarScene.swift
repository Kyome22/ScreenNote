import Model
import SwiftUI

public struct MenuBarScene: Scene {
    @Environment(\.appDependencies) private var appDependencies

    public init() {}

    public var body: some Scene {
        MenuBarExtra {
            MainMenuView(store: .init(appDependencies))
        } label: {
            Image("StatusIcon", bundle: .module)
                .environment(\.displayScale, 2)
        }
    }
}
