import Foundation
import SpiceKey

public struct AppState: Sendable {
    public var environmentInfo: EnvironmentInfo
    public var hasAlreadyBootstrap: Bool
    public var spiceKey: SpiceKey?
    public var undoStack: [[Object]]
    public var redoStack: [[Object]]
    public var dragContext = DragContext()
    public var canvasVisibility = AsyncStreamBundle<CanvasVisibility>()
    public var canvasState = AsyncStreamBundle<CanvasState>()

    init(
        environmentInfo: EnvironmentInfo = .unknown,
        hasAlreadyBootstrap: Bool = false,
        spiceKey: SpiceKey? = nil,
        undoStack: [[Object]] = [],
        redoStack: [[Object]] = []
    ) {
        self.environmentInfo = environmentInfo
        self.hasAlreadyBootstrap = hasAlreadyBootstrap
        self.spiceKey = spiceKey
        self.undoStack = undoStack
        self.redoStack = redoStack
    }
}
