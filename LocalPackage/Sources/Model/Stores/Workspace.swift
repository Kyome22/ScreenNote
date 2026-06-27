import CoreGraphics
import DataSource
import Observation

@MainActor @Observable
public final class Workspace: Composable {
    private let appStateClient: AppStateClient
    private let objectService: ObjectService
    private let logService: LogService

    @ObservationIgnored private var task: Task<Void, Never>?

    public var toolBarPosition: ToolBarPosition
    public var canvasState: CanvasState
    public var inputText: String
    public var showingColorPopover: Bool
    public var showingLineWidthPopover: Bool
    public var showingArrangePopover: Bool
    public var showingAlignPopover: Bool
    public var showingFlipPopover: Bool
    public var showingRotatePopover: Bool
    public let action: (Action) async -> Void

    public var disabledWhileInputtingText: Bool {
        canvasState.inputTextProperties != nil
    }

    public var disabledEditObject: Bool {
        !canvasState.isSelecting
    }

    public init(
        _ appDependencies: AppDependencies,
        toolBarPosition: ToolBarPosition? = nil,
        canvasState: CanvasState = .init(),
        inputText: String = "",
        showingColorPopover: Bool = false,
        showingLineWidthPopover: Bool = false,
        showingArrangePopover: Bool = false,
        showingAlignPopover: Bool = false,
        showingFlipPopover: Bool = false,
        showingRotatePopover: Bool = false,
        action: @escaping (Action) async -> Void = { _ in }
    ) {
        self.appStateClient = appDependencies.appStateClient
        self.objectService = .init(appDependencies)
        self.logService = .init(appDependencies)
        let userDefaultsRepository = UserDefaultsRepository(appDependencies.userDefaultsClient)
        self.toolBarPosition = toolBarPosition ?? userDefaultsRepository.toolBarPosition
        self.canvasState = canvasState
        self.inputText = inputText
        self.showingColorPopover = showingColorPopover
        self.showingLineWidthPopover = showingLineWidthPopover
        self.showingArrangePopover = showingArrangePopover
        self.showingAlignPopover = showingAlignPopover
        self.showingFlipPopover = showingFlipPopover
        self.showingRotatePopover = showingRotatePopover
        self.action = action
    }

    public func reduce(_ action: Action) async {
        switch action {
        case let .task(screenName):
            logService.notice(.screenView(name: screenName))
            if let latestValue = appStateClient.withLock(\.canvasState.latestValue) {
                applyCanvasState(latestValue)
            }
            task?.cancel()
            task = Task { [weak self, appStateClient] in
                let stream = appStateClient.withLock(\.canvasState.stream)
                for await value in stream {
                    self?.applyCanvasState(value)
                }
            }

        case .onDisappear:
            task?.cancel()
            task = nil

        case let .dragBegan(location):
            objectService.dragBegan(location: location)

        case let .dragMoved(startLocation, location):
            objectService.dragMoved(startLocation: startLocation, location: location)

        case let .dragEnded(startLocation, location):
            objectService.dragEnded(startLocation: startLocation, location: location)

        case let .inputTextChanged(inputText):
            self.inputText = inputText

        case .inputTextSubmitted:
            if var inputTextProperties = canvasState.inputTextProperties {
                inputTextProperties.inputText = inputText
                objectService.endEditing(inputTextProperties)
            }

        case .undoButtonTapped:
            objectService.undo()

        case .redoButtonTapped:
            objectService.redo()

        case let .objectTypeSelected(objectType):
            objectService.updateObjectType(objectType)

        case .colorButtonTapped:
            showingColorPopover = true

        case let .colorSelected(paletteIndex):
            objectService.updateColor(paletteIndex)

        case .opacityUpdateBegan:
            objectService.startUpdatingOpacity()

        case let .opacityChanged(opacity):
            objectService.updateOpacity(opacity)

        case .lineWidthButtonTapped:
            showingLineWidthPopover = true

        case .lineWidthUpdateBegan:
            objectService.startUpdatingLineWidth()

        case let .lineWidthChanged(lineWidth):
            objectService.updateLineWidth(lineWidth)

        case .arrangeButtonTapped:
            showingArrangePopover = true

        case let .arrangeSelected(arrangeMethod):
            objectService.arrange(arrangeMethod)

        case .alignButtonTapped:
            showingAlignPopover = true

        case let .alignSelected(alignMethod):
            objectService.align(alignMethod)

        case .flipButtonTapped:
            showingFlipPopover = true

        case let .flipSelected(flipMethod):
            objectService.flip(flipMethod)

        case .rotateButtonTapped:
            showingRotatePopover = true

        case let .rotateSelected(rotateMethod):
            objectService.rotate(rotateMethod)

        case .duplicateButtonTapped:
            objectService.duplicateSelectedObjects()

        case .deleteButtonTapped:
            objectService.delete()

        case .selectAllButtonTapped:
            objectService.selectAll()

        case .clearButtonTapped:
            objectService.clear()
        }
    }

    private func applyCanvasState(_ newValue: CanvasState) {
        let previousInputObjectID = canvasState.inputTextProperties?.object.id
        canvasState = newValue
        if let inputTextProperties = newValue.inputTextProperties,
           inputTextProperties.object.id != previousInputObjectID {
            inputText = inputTextProperties.inputText
        }
    }

    public enum Action: Sendable {
        case task(String)
        case onDisappear
        case dragBegan(CGPoint)
        case dragMoved(CGPoint, CGPoint)
        case dragEnded(CGPoint, CGPoint)
        case inputTextChanged(String)
        case inputTextSubmitted
        case undoButtonTapped
        case redoButtonTapped
        case objectTypeSelected(ObjectType)
        case colorButtonTapped
        case colorSelected(Int)
        case opacityUpdateBegan
        case opacityChanged(CGFloat)
        case lineWidthButtonTapped
        case lineWidthUpdateBegan
        case lineWidthChanged(CGFloat)
        case arrangeButtonTapped
        case arrangeSelected(ArrangeMethod)
        case alignButtonTapped
        case alignSelected(AlignMethod)
        case flipButtonTapped
        case flipSelected(FlipMethod)
        case rotateButtonTapped
        case rotateSelected(RotateMethod)
        case duplicateButtonTapped
        case deleteButtonTapped
        case selectAllButtonTapped
        case clearButtonTapped
    }
}
