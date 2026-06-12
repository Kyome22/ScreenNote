import CoreGraphics
import DataSource
import Observation

@MainActor @Observable
public final class Workspace: Composable {
    private let appStateClient: AppStateClient
    private let objectService: ObjectService
    private let logService: LogService
    @ObservationIgnored private var observationTask: Task<Void, Never>?

    public var canvasState: CanvasState
    public var inputText: String
    public var showColorPopover = false
    public var showLineWidthPopover = false
    public var showArrangePopover = false
    public var showAlignPopover = false
    public var showFlipPopover = false
    public var showRotatePopover = false
    public let toolBarPosition: ToolBarPosition
    public let action: (Action) async -> Void

    public var disabledWhileInputtingText: Bool {
        canvasState.inputTextProperties != nil
    }

    public var disabledEditObject: Bool {
        !canvasState.isSelecting
    }

    public init(
        _ appDependencies: AppDependencies,
        canvasState: CanvasState? = nil,
        toolBarPosition: ToolBarPosition? = nil,
        action: @escaping (Action) async -> Void = { _ in }
    ) {
        self.appStateClient = appDependencies.appStateClient
        self.objectService = .init(appDependencies)
        self.logService = .init(appDependencies)
        let userDefaultsRepository = UserDefaultsRepository(
            appDependencies.userDefaultsClient,
            appDependencies.appStateClient
        )
        let initialCanvasState = canvasState
            ?? appDependencies.appStateClient.withLock(\.canvasState.latestValue)
            ?? CanvasState()
        self.canvasState = initialCanvasState
        self.inputText = initialCanvasState.inputTextProperties?.inputText ?? ""
        self.toolBarPosition = toolBarPosition ?? userDefaultsRepository.toolBarPosition
        self.action = action
    }

    public func reduce(_ action: Action) async {
        switch action {
        case let .task(screenName):
            logService.notice(.screenView(name: screenName))
            observeCanvasState()

        case .onDisappear:
            observationTask?.cancel()
            observationTask = nil

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

        case let .colorSelected(paletteIndex):
            objectService.updateColor(paletteIndex)

        case .opacityUpdateBegan:
            objectService.startUpdatingOpacity()

        case let .opacityChanged(opacity):
            objectService.updateOpacity(opacity)

        case .lineWidthUpdateBegan:
            objectService.startUpdatingLineWidth()

        case let .lineWidthChanged(lineWidth):
            objectService.updateLineWidth(lineWidth)

        case let .arrangeSelected(arrangeMethod):
            objectService.arrange(arrangeMethod)

        case let .alignSelected(alignMethod):
            objectService.align(alignMethod)

        case let .flipSelected(flipMethod):
            objectService.flip(flipMethod)

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

        case let .colorPopoverPresented(isPresented):
            showColorPopover = isPresented

        case let .lineWidthPopoverPresented(isPresented):
            showLineWidthPopover = isPresented

        case let .arrangePopoverPresented(isPresented):
            showArrangePopover = isPresented

        case let .alignPopoverPresented(isPresented):
            showAlignPopover = isPresented

        case let .flipPopoverPresented(isPresented):
            showFlipPopover = isPresented

        case let .rotatePopoverPresented(isPresented):
            showRotatePopover = isPresented
        }
    }

    private func observeCanvasState() {
        observationTask?.cancel()
        if let latestValue = appStateClient.withLock(\.canvasState.latestValue) {
            applyCanvasState(latestValue)
        }
        let appStateClient = self.appStateClient
        observationTask = Task { [weak self] in
            let stream = appStateClient.withLock(\.canvasState.stream)
            for await value in stream {
                self?.applyCanvasState(value)
            }
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
        case colorSelected(Int)
        case opacityUpdateBegan
        case opacityChanged(CGFloat)
        case lineWidthUpdateBegan
        case lineWidthChanged(CGFloat)
        case arrangeSelected(ArrangeMethod)
        case alignSelected(AlignMethod)
        case flipSelected(FlipMethod)
        case rotateSelected(RotateMethod)
        case duplicateButtonTapped
        case deleteButtonTapped
        case selectAllButtonTapped
        case clearButtonTapped
        case colorPopoverPresented(Bool)
        case lineWidthPopoverPresented(Bool)
        case arrangePopoverPresented(Bool)
        case alignPopoverPresented(Bool)
        case flipPopoverPresented(Bool)
        case rotatePopoverPresented(Bool)
    }
}
