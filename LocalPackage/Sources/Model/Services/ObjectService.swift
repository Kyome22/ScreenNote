import CoreGraphics
import DataSource

public struct ObjectService: Sendable {
    private let appStateClient: AppStateClient
    private let userDefaultsRepository: UserDefaultsRepository

    private static let levelsOfUndo = 15

    public init(_ appDependencies: AppDependencies) {
        self.appStateClient = appDependencies.appStateClient
        self.userDefaultsRepository = .init(
            appDependencies.userDefaultsClient,
            appDependencies.appStateClient
        )
    }

    func dragBegan(location: CGPoint) {
        appStateClient.withLock { appState in
            var state = appState.canvasState.latestValue ?? CanvasState()
            switch state.objectType {
            case .select:
                pushHistory(&appState, snapshot: unselectedObjects(state.objects))
                dragBeganWithSelect(&appState, &state, location: location)
            case .text:
                dragBeganWithText(&appState, &state, location: location)
            case .pen:
                pushHistory(&appState, snapshot: unselectedObjects(state.objects))
                state.objects.append(Object(
                    .pen,
                    state.objectProperties.paletteIndex,
                    state.objectProperties.opacity,
                    state.objectProperties.lineWidth,
                    [location]
                ))
            default:
                pushHistory(&appState, snapshot: unselectedObjects(state.objects))
                state.objects.append(Object(
                    state.objectType,
                    state.objectProperties.paletteIndex,
                    state.objectProperties.opacity,
                    state.objectProperties.lineWidth,
                    [location, location]
                ))
            }
            appState.canvasState.send(state)
        }
    }

    func dragMoved(startLocation: CGPoint, location: CGPoint) {
        appStateClient.withLock { appState in
            var state = appState.canvasState.latestValue ?? CanvasState()
            switch state.objectType {
            case .select:
                state.rectangleForSelection?.points[1] = location
                let diff = location - startLocation
                switch appState.dragContext.action {
                case .none:
                    break
                case .move:
                    state.objects = moved(appState.dragContext.lastObjects, diff: diff)
                case .resize:
                    state.objects = resized(
                        appState.dragContext.lastObjects,
                        anchor: appState.dragContext.anchor,
                        diff: diff
                    )
                }
            case .text:
                break
            case .pen:
                if !state.objects.isEmpty {
                    state.objects[state.objects.count - 1].points.append(location)
                }
            default:
                if !state.objects.isEmpty {
                    state.objects[state.objects.count - 1].points[1] = location
                }
            }
            appState.canvasState.send(state)
        }
    }

    func dragEnded(startLocation: CGPoint, location: CGPoint) {
        appStateClient.withLock { appState in
            var state = appState.canvasState.latestValue ?? CanvasState()
            switch state.objectType {
            case .select:
                dragEndedWithSelect(&appState, &state, startLocation: startLocation, location: location)
            case .text, .pen:
                break
            default:
                if startLocation.length(from: location) < 5 {
                    undo(&appState, &state)
                }
            }
            appState.canvasState.send(state)
        }
    }

    func endEditing(_ inputTextProperties: InputTextProperties) {
        appStateClient.withLock { appState in
            var state = appState.canvasState.latestValue ?? CanvasState()
            endEditing(&appState, &state, inputTextProperties)
            appState.canvasState.send(state)
        }
    }

    public func resetDefaultSettings() {
        appStateClient.withLock { appState in
            var state = appState.canvasState.latestValue ?? CanvasState()
            state.objectType = userDefaultsRepository.defaultObjectType
            state.objectProperties = ObjectProperties(
                paletteIndex: userDefaultsRepository.defaultColorIndex,
                opacity: userDefaultsRepository.defaultOpacity,
                lineWidth: userDefaultsRepository.defaultLineWidth
            )
            appState.canvasState.send(state)
        }
    }

    public func resetHistory() {
        appStateClient.withLock { appState in
            var state = appState.canvasState.latestValue ?? CanvasState()
            state.objectType = .pen
            state.objects = []
            state.objectProperties = ObjectProperties(
                paletteIndex: userDefaultsRepository.defaultColorIndex,
                opacity: userDefaultsRepository.defaultOpacity,
                lineWidth: userDefaultsRepository.defaultLineWidth
            )
            state.inputTextProperties = nil
            appState.undoStack = []
            appState.redoStack = []
            appState.canvasState.send(state)
        }
    }

    func undo() {
        appStateClient.withLock { appState in
            var state = appState.canvasState.latestValue ?? CanvasState()
            guard state.inputTextProperties == nil else { return }
            undo(&appState, &state)
            appState.canvasState.send(state)
        }
    }

    func redo() {
        appStateClient.withLock { appState in
            var state = appState.canvasState.latestValue ?? CanvasState()
            guard state.inputTextProperties == nil, !appState.redoStack.isEmpty else { return }
            let objects = appState.redoStack.removeLast()
            appState.undoStack.append(unselectedObjects(state.objects))
            state.objects = objects
            appState.canvasState.send(state)
        }
    }

    func updateObjectType(_ objectType: ObjectType) {
        appStateClient.withLock { appState in
            var state = appState.canvasState.latestValue ?? CanvasState()
            guard state.objectType != objectType else { return }
            if state.objectType == .text, let inputTextProperties = state.inputTextProperties {
                endEditing(&appState, &state, inputTextProperties)
            }
            state.objectType = objectType
            if objectType != .select, !state.selectedObjects.isEmpty {
                state.objects = unselectedObjects(state.objects)
            }
            appState.canvasState.send(state)
        }
    }

    func updateColor(_ paletteIndex: Int) {
        appStateClient.withLock { appState in
            var state = appState.canvasState.latestValue ?? CanvasState()
            state.objectProperties.paletteIndex = paletteIndex
            if !state.selectedObjects.isEmpty {
                pushHistory(&appState, snapshot: unselectedObjects(state.objects))
                for index in state.objects.indices where state.objects[index].isSelected {
                    state.objects[index].paletteIndex = paletteIndex
                }
            }
            appState.canvasState.send(state)
        }
    }

    func startUpdatingOpacity() {
        pushHistoryIfSelecting()
    }

    func updateOpacity(_ opacity: CGFloat) {
        appStateClient.withLock { appState in
            var state = appState.canvasState.latestValue ?? CanvasState()
            state.objectProperties.opacity = opacity
            for index in state.objects.indices where state.objects[index].isSelected {
                state.objects[index].opacity = opacity
            }
            appState.canvasState.send(state)
        }
    }

    func startUpdatingLineWidth() {
        pushHistoryIfSelecting()
    }

    func updateLineWidth(_ lineWidth: CGFloat) {
        appStateClient.withLock { appState in
            var state = appState.canvasState.latestValue ?? CanvasState()
            state.objectProperties.lineWidth = lineWidth
            for index in state.objects.indices where state.objects[index].isSelected {
                state.objects[index].lineWidth = lineWidth
            }
            appState.canvasState.send(state)
        }
    }

    func arrange(_ arrangeMethod: ArrangeMethod) {
        mutateSelection { appState, state in
            pushHistory(&appState, snapshot: unselectedObjects(state.objects))
            let selectedObjects = state.selectedObjects
            state.objects.removeAll(where: \.isSelected)
            switch arrangeMethod {
            case .bringToFrontmost:
                state.objects.append(contentsOf: selectedObjects)
            case .sendToBackmost:
                state.objects.insert(contentsOf: selectedObjects, at: 0)
            }
        }
    }

    func align(_ alignMethod: AlignMethod) {
        mutateSelection { appState, state in
            guard let bounds = state.selectedObjectsBounds else { return }
            pushHistory(&appState, snapshot: unselectedObjects(state.objects))
            for index in state.objects.indices where state.objects[index].isSelected {
                let diff: CGFloat = switch alignMethod {
                case .horizontalAlignLeft:   bounds.minX - state.objects[index].bounds.minX
                case .horizontalAlignCenter: bounds.midX - state.objects[index].bounds.midX
                case .horizontalAlignRight:  bounds.maxX - state.objects[index].bounds.maxX
                case .verticalAlignTop:      bounds.minY - state.objects[index].bounds.minY
                case .verticalAlignCenter:   bounds.midY - state.objects[index].bounds.midY
                case .verticalAlignBottom:   bounds.maxY - state.objects[index].bounds.maxY
                }
                for pointIndex in state.objects[index].points.indices {
                    if AlignMethod.horizontals.contains(alignMethod) {
                        state.objects[index].points[pointIndex].x += diff
                    } else {
                        state.objects[index].points[pointIndex].y += diff
                    }
                }
            }
        }
    }

    func flip(_ flipMethod: FlipMethod) {
        mutateSelection { appState, state in
            guard let bounds = state.selectedObjectsBounds else { return }
            pushHistory(&appState, snapshot: unselectedObjects(state.objects))
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            for index in state.objects.indices where state.objects[index].isSelected {
                state.objects[index].points = state.objects[index].points.map { point in
                    switch flipMethod {
                    case .flipHorizontal:
                        CGPoint(x: 2.0 * center.x - point.x, y: point.y)
                    case .flipVertical:
                        CGPoint(x: point.x, y: 2.0 * center.y - point.y)
                    }
                }
                if state.objects[index].type == .text {
                    state.objects[index].textOrientation = state.objects[index].textOrientation.flip(flipMethod)
                }
            }
        }
    }

    func rotate(_ rotateMethod: RotateMethod) {
        mutateSelection { appState, state in
            guard let bounds = state.selectedObjectsBounds else { return }
            pushHistory(&appState, snapshot: unselectedObjects(state.objects))
            let offset = CGPoint(
                x: bounds.origin.x + 0.5 * bounds.width,
                y: bounds.origin.y + 0.5 * bounds.height
            )
            let transforms: [CGAffineTransform] = [
                .init(translationX: -offset.x, y: -offset.y),
                .init(rotationAngle: rotateMethod.angle),
                .init(translationX: offset.x, y: offset.y),
            ]
            for index in state.objects.indices where state.objects[index].isSelected {
                state.objects[index].points = state.objects[index].points.map { point in
                    transforms.reduce(point) { partialResult, transform in
                        partialResult.applying(transform)
                    }
                }
                if state.objects[index].type == .text {
                    state.objects[index].textOrientation = state.objects[index].textOrientation.rotate(rotateMethod)
                }
            }
        }
    }

    func duplicateSelectedObjects() {
        mutateSelection { appState, state in
            pushHistory(&appState, snapshot: unselectedObjects(state.objects))
            let copiedObjects = state.selectedObjects.map { $0.copy(needsOffset: true) }
            state.objects = unselectedObjects(state.objects)
            state.objects.append(contentsOf: copiedObjects)
        }
    }

    func delete() {
        mutateSelection { appState, state in
            pushHistory(&appState, snapshot: unselectedObjects(state.objects))
            state.objects.removeAll(where: \.isSelected)
        }
    }

    func selectAll() {
        appStateClient.withLock { appState in
            var state = appState.canvasState.latestValue ?? CanvasState()
            guard state.objectType == .select else { return }
            for index in state.objects.indices {
                state.objects[index].isSelected = true
            }
            appState.canvasState.send(state)
        }
    }

    func clear() {
        appStateClient.withLock { appState in
            var state = appState.canvasState.latestValue ?? CanvasState()
            guard state.inputTextProperties == nil, !state.objects.isEmpty else { return }
            pushHistory(&appState, snapshot: unselectedObjects(state.objects))
            state.objects = []
            appState.canvasState.send(state)
        }
    }

    private func dragBeganWithSelect(_ appState: inout AppState, _ state: inout CanvasState, location: CGPoint) {
        let selectedObjects = state.selectedObjects
        if let bounds = state.selectedObjectsBounds,
           let anchor = Anchor.hitAnchor(of: location, in: bounds) {
            appState.dragContext.selectType = .keep
            if selectedObjects.count == 1,
               let index = state.objects.firstIndex(where: \.isSelected),
               state.objects[index].bounds.isEmpty {
                appState.dragContext.action = .move
            } else {
                appState.dragContext.action = .resize
                appState.dragContext.anchor = anchor
            }
        } else if selectedObjects.contains(where: { $0.isHit(point: location) }) {
            appState.dragContext.selectType = .keep
            appState.dragContext.action = .move
        } else if let index = state.objects.lastIndex(where: { $0.isHit(point: location) }) {
            appState.dragContext.selectType = .selectOne(index)
            appState.dragContext.action = .move
            state.objects = unselectedObjects(state.objects)
            state.objects[index].isSelected = true
        } else {
            appState.dragContext.selectType = .rectangle
            appState.dragContext.action = .none
            state.objects = unselectedObjects(state.objects)
            state.rectangleForSelection = Object(
                .select,
                0,
                1.0,
                state.objectProperties.lineWidth,
                [location, location]
            )
        }
        appState.dragContext.lastObjects = state.objects
    }

    private func dragBeganWithText(_ appState: inout AppState, _ state: inout CanvasState, location: CGPoint) {
        if let inputTextProperties = state.inputTextProperties {
            endEditing(&appState, &state, inputTextProperties)
        }
        if let index = state.objects.lastIndex(where: { object in
            object.type == .text && object.isHit(point: location)
        }) {
            state.inputTextProperties = InputTextProperties(
                object: state.objects[index],
                inputText: state.objects[index].text,
                fontSize: state.objects[index].fontSize
            )
            state.objects[index].isHidden = true
        } else {
            state.inputTextProperties = InputTextProperties(
                object: Object(
                    state.objectProperties.paletteIndex,
                    state.objectProperties.opacity,
                    [location],
                    "",
                    .up
                ),
                inputText: "",
                fontSize: 40.0
            )
        }
    }

    private func dragEndedWithSelect(
        _ appState: inout AppState,
        _ state: inout CanvasState,
        startLocation: CGPoint,
        location: CGPoint
    ) {
        if startLocation == location {
            undo(&appState, &state)
        } else if case .rectangle = appState.dragContext.selectType {
            undo(&appState, &state)
        }
        if case let .selectOne(index) = appState.dragContext.selectType {
            state.objects[index].isSelected = true
        } else if case .rectangle = appState.dragContext.selectType {
            if let selectionBounds = state.rectangleForSelection?.bounds {
                for index in state.objects.indices {
                    state.objects[index].isSelected = state.objects[index].isHit(rect: selectionBounds)
                }
            }
        }
        appState.dragContext.action = .none
        state.rectangleForSelection = nil
        appState.dragContext.lastObjects = []
    }

    private func endEditing(
        _ appState: inout AppState,
        _ state: inout CanvasState,
        _ inputTextProperties: InputTextProperties
    ) {
        let position = inputTextProperties.object.points[0]
        let inputText = inputTextProperties.inputText
        let fontSize = inputTextProperties.fontSize
        let size = inputText.calculateSize(using: .systemFont(ofSize: fontSize))
        if let index = state.objects.firstIndex(where: { object in
            object.type == .text && object.isHidden
        }) {
            state.objects[index].isHidden = false
            if inputText.isEmpty {
                pushHistory(&appState, snapshot: unselectedObjects(state.objects))
                state.objects.remove(at: index)
            } else if inputText != state.objects[index].text {
                var object = state.objects[index]
                let endPosition = object.textOrientation.endPosition(with: position, size: size)
                pushHistory(&appState, snapshot: unselectedObjects(state.objects))
                object.points = [position, endPosition]
                object.text = inputText
                state.objects[index] = object
            }
        } else if !inputText.isEmpty {
            let endPosition = CGPoint(x: position.x + size.width, y: position.y + size.height)
            pushHistory(&appState, snapshot: unselectedObjects(state.objects))
            state.objects.append(Object(
                inputTextProperties.object.paletteIndex,
                inputTextProperties.object.opacity,
                [position, endPosition],
                inputText,
                .up
            ))
        }
        state.inputTextProperties = nil
    }

    private func mutateSelection(_ body: @Sendable (inout AppState, inout CanvasState) -> Void) {
        appStateClient.withLock { appState in
            var state = appState.canvasState.latestValue ?? CanvasState()
            guard state.isSelecting else { return }
            body(&appState, &state)
            appState.canvasState.send(state)
        }
    }

    private func pushHistoryIfSelecting() {
        appStateClient.withLock { appState in
            let state = appState.canvasState.latestValue ?? CanvasState()
            guard !state.selectedObjects.isEmpty else { return }
            pushHistory(&appState, snapshot: unselectedObjects(state.objects))
        }
    }

    private func pushHistory(_ appState: inout AppState, snapshot: [Object]) {
        appState.undoStack.append(snapshot)
        if Self.levelsOfUndo < appState.undoStack.count {
            appState.undoStack.removeFirst()
        }
        appState.redoStack = []
    }

    private func undo(_ appState: inout AppState, _ state: inout CanvasState) {
        guard let objects = appState.undoStack.popLast() else { return }
        appState.redoStack.append(unselectedObjects(state.objects))
        state.objects = objects
    }

    private func moved(_ lastObjects: [Object], diff: CGPoint) -> [Object] {
        lastObjects.map { object in
            guard object.isSelected else { return object }
            var copyObject = object.copy()
            copyObject.points = copyObject.points.map { $0 + diff }
            return copyObject
        }
    }

    private func resized(_ lastObjects: [Object], anchor: Anchor, diff: CGPoint) -> [Object] {
        let lastSelectedObjects = lastObjects.filter(\.isSelected)
        guard let oldBounds = CanvasState.bounds(of: lastSelectedObjects) else {
            return lastObjects
        }
        let newBounds = anchor.resize(bounds: oldBounds, with: diff)
        let transforms: [CGAffineTransform] = [
            .init(translationX: -oldBounds.origin.x, y: -oldBounds.origin.y),
            .init(
                scaleX: newBounds.size.width / oldBounds.width,
                y: newBounds.size.height / oldBounds.height
            ),
            .init(translationX: newBounds.origin.x, y: newBounds.origin.y),
        ]
        return lastObjects.map { object in
            guard object.isSelected else { return object }
            var copyObject = object.copy()
            copyObject.points = copyObject.points.map { point in
                transforms.reduce(point) { partialResult, transform in
                    partialResult.applying(transform)
                }
            }
            return copyObject
        }
    }

    private func unselectedObjects(_ objects: [Object]) -> [Object] {
        var unselected = objects
        for index in unselected.indices where unselected[index].isSelected {
            unselected[index].isSelected = false
        }
        return unselected
    }
}
