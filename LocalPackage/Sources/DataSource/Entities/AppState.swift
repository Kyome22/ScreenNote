import Foundation

public struct AppState: Sendable {
    public var name: String
    public var version: String
    public var hasAlreadyBootstrap: Bool
    public var undoStack: [[Object]]
    public var redoStack: [[Object]]
    public var dragContext = DragContext()
    public var canvasState = AsyncStreamBundle<CanvasState>()
    public var canvasVisible = AsyncStreamBundle<CanvasVisible>()
    public var shortcutSettings = AsyncStreamBundle<Void>(replaysLatestValue: false)
    public var shortcutCommand = AsyncStreamBundle<Void>(replaysLatestValue: false)

    init(
        name: String = "",
        version: String = "",
        hasAlreadyBootstrap: Bool = false,
        undoStack: [[Object]] = [],
        redoStack: [[Object]] = []
    ) {
        self.name = name
        self.version = version
        self.hasAlreadyBootstrap = hasAlreadyBootstrap
        self.undoStack = undoStack
        self.redoStack = redoStack
    }
}
