import Foundation

public struct AppState: Sendable {
    public var name: String
    public var version: String
    public var hasAlreadyBootstrap: Bool
    // MIGRATION: Phase 3 adds canvasState, canvasVisible, shortcutSettings, shortcutCommand bundles
    // and the undo/redo snapshot stacks.

    init(
        name: String = "",
        version: String = "",
        hasAlreadyBootstrap: Bool = false
    ) {
        self.name = name
        self.version = version
        self.hasAlreadyBootstrap = hasAlreadyBootstrap
    }
}
