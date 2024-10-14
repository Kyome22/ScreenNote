/*
  ObjectModel.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SwiftUI
import Combine

protocol ObjectModel: AnyObject {
    var colors: [[Color]] { get }
    var objectTypePublisher: AnyPublisher<ObjectType, Never> { get }
    var objectType: ObjectType { get }
    var objectsPublisher: AnyPublisher<[Object], Never> { get }
    var selectedObjectsBoundsPublisher: AnyPublisher<CGRect?, Never> { get }
    var isSelectingPublisher: AnyPublisher<Bool, Never> { get }
    var objectPropertiesPublisher: AnyPublisher<ObjectProperties, Never> { get }
    var color: Color { get }
    var opacity: CGFloat { get }
    var lineWidth: CGFloat { get }
    var inputTextPropertiesPublisher: AnyPublisher<InputTextProperties?, Never> { get }

    init(_ userDefaultsRepository: UserDefaultsRepository)

    func endEditing(_ inputTextProperties: InputTextProperties)
    func dragBegan(location: CGPoint,
                   selectBeganHandler: @escaping () -> Void)
    func dragMoved(startLocation: CGPoint,
                   location: CGPoint,
                   selectMovedHandler: @escaping () -> Void)
    func dragEnded(startLocation: CGPoint,
                   location: CGPoint,
                   selectionBounds: CGRect?,
                   selectEndedHandler: @escaping () -> Void)

    func undo()
    func redo()
    func resetHistory()
    func updateObjectType(_ objectType: ObjectType)
    func updateColor(_ color: Color)
    func startUpdatingOpacity()
    func updateOpacity(_ opacity: CGFloat)
    func startUpdatingLineWidth()
    func updateLineWidth(_ lineWidth: CGFloat)
    func arrange(_ arrangeMethod: ArrangeMethod)
    func align(_ alignMethod: AlignMethod)
    func flip(_ flipMethod: FlipMethod)
    func rotate(_ rotateMethod: RotateMethod)
    func duplicateSelectedObjects()
    func delete()
    func selectAll()
    func clear()
}

final class ObjectModelImpl: ObjectModel {
    enum Action {
        case none
        case move
        case resize
    }

    enum SelectType {
        case rectangle
        case selectOne(Int)
        case keep
    }

    private let userDefaultsRepository: UserDefaultsRepository
    private let undoManager = UndoManager()
    private var lastObjects = [Object]()
    private var currentAction: Action = .none
    private var currentAnchor: Anchor = .topLeft
    private var currentSelectType: SelectType = .rectangle
    private var cancellables = Set<AnyCancellable>()

    let colors: [[Color]]

    private let objectTypeSubject = CurrentValueSubject<ObjectType, Never>(.pen)
    var objectTypePublisher: AnyPublisher<ObjectType, Never> {
        objectTypeSubject.eraseToAnyPublisher()
    }
    var objectType: ObjectType {
        objectTypeSubject.value
    }

    private let objectsSubject = CurrentValueSubject<[Object], Never>([])
    var objectsPublisher: AnyPublisher<[Object], Never> {
        objectsSubject.eraseToAnyPublisher()
    }
    private var objects: [Object] {
        objectsSubject.value
    }
    private var selectedObjects: [Object] {
        objectsSubject.value.filter { $0.isSelected }
    }

    private var selectedObjectsBoundsSubject = CurrentValueSubject<CGRect?, Never>(nil)
    var selectedObjectsBoundsPublisher: AnyPublisher<CGRect?, Never> {
        selectedObjectsBoundsSubject.eraseToAnyPublisher()
    }
    private var selectedObjectsBounds: CGRect? {
        selectedObjectsBoundsSubject.value
    }

    private let isSelectingSubject = CurrentValueSubject<Bool, Never>(false)
    var isSelectingPublisher: AnyPublisher<Bool, Never> {
        isSelectingSubject.eraseToAnyPublisher()
    }
    private var isSelecting: Bool {
        isSelectingSubject.value
    }

    private let objectPropertiesSubject: CurrentValueSubject<ObjectProperties, Never>
    var objectPropertiesPublisher: AnyPublisher<ObjectProperties, Never> {
        objectPropertiesSubject.eraseToAnyPublisher()
    }
    var color: Color {
        objectPropertiesSubject.value.color
    }
    var opacity: CGFloat {
        objectPropertiesSubject.value.opacity
    }
    var lineWidth: CGFloat {
        objectPropertiesSubject.value.lineWidth
    }

    private let inputTextPropertiesSubject = CurrentValueSubject<InputTextProperties?, Never>(nil)
    var inputTextPropertiesPublisher: AnyPublisher<InputTextProperties?, Never> {
        inputTextPropertiesSubject.eraseToAnyPublisher()
    }

    init(_ userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
        colors = Color.palette
        let index = userDefaultsRepository.defaultColorIndex
        objectPropertiesSubject = .init(ObjectProperties(
            color: colors[index % 8][index / 8],
            opacity: userDefaultsRepository.defaultOpacity,
            lineWidth: userDefaultsRepository.defaultLineWidth
        ))
        undoManager.levelsOfUndo = 15
        objectsPublisher
            .sink { [weak self] _ in
                self?.updatedObjects()
            }
            .store(in: &cancellables)
    }

    private func unselectedObjects() -> [Object] {
        var objects_ = objects
        for i in objects_.indices where objects_[i].isSelected {
            objects_[i].isSelected = false
        }
        return objects_
    }

    private func objectsBounds(_ objects: [Object]) -> CGRect? {
        objects.reduce(CGRect?.none) { partialResult, object in
            return partialResult?.union(object.bounds) ?? object.bounds
        }
    }

    private func updatedObjects() {
        let bounds = objectsBounds(selectedObjects)
        selectedObjectsBoundsSubject.send(bounds)
        let isSelecting = (objectType == .select && bounds != nil)
        isSelectingSubject.send(isSelecting)
    }

    private func hitAnchor(_ point: CGPoint) -> Anchor? {
        guard let bounds = objectsBounds(selectedObjects) else { return nil }
        let anchors = Path.anchorPaths(bounds: bounds)
        return zip(anchors, Anchor.allCases)
            .first { $0.0.contains(point) }?.1
    }

    private func move(_ diff: CGPoint) -> [Object] {
        lastObjects.map { object in
            guard object.isSelected else { return object }
            var copyObject = object.copy()
            copyObject.points = copyObject.points.map { $0 + diff }
            return copyObject
        }
    }

    private func resize(_ diff: CGPoint) -> [Object] {
        let lastSelectedObjects = lastObjects.filter { $0.isSelected }
        guard let oldBounds = objectsBounds(lastSelectedObjects) else {
            return lastObjects
        }
        let newBounds = currentAnchor.resize(bounds: oldBounds, with: diff)
        // Do not refactor
        let transforms: [CGAffineTransform] = [
            .init(translationX: -oldBounds.origin.x, y: -oldBounds.origin.y),
            .init(scaleX: newBounds.size.width / oldBounds.width,
                  y: newBounds.size.height / oldBounds.height),
            .init(translationX: newBounds.origin.x, y: newBounds.origin.y)
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

    func dragBegan(
        location: CGPoint,
        selectBeganHandler: @escaping () -> Void
    ) {
        switch objectType {
        case .select:
            pushHistory()
            if let anchor = hitAnchor(location) {
                currentSelectType = .keep
                // もしも選択中の図形が大きさを持たなかった場合はresizeではなくmoveにする
                if selectedObjects.count == 1,
                   let index = objects.firstIndex(where: { $0.isSelected }),
                   objects[index].bounds.isEmpty {
                    currentAction = .move
                } else {
                    currentAction = .resize
                    currentAnchor = anchor
                }
            } else if selectedObjects.contains(where: { $0.isHit(point: location) }) {
                currentSelectType = .keep
                currentAction = .move
            } else if let index = objects.lastIndex(where: { $0.isHit(point: location) }) {
                currentSelectType = .selectOne(index)
                currentAction = .move
                var objects_ = unselectedObjects()
                objects_[index].isSelected = true
                objectsSubject.send(objects_)
            } else {
                currentSelectType = .rectangle
                currentAction = .none
                objectsSubject.send(unselectedObjects())
                selectBeganHandler()
            }
            lastObjects = objects
        case .text:
            if let inputTextProperties = inputTextPropertiesSubject.value {
                endEditing(inputTextProperties)
            }
            if let index = objects.lastIndex(where: { object in
                object.type == .text && object.isHit(point: location)
            }) {
                let properties = InputTextProperties(
                    object: objects[index],
                    inputText: objects[index].text,
                    fontSize: objects[index].fontSize
                )
                inputTextPropertiesSubject.send(properties)
                objectsSubject.value[index].isHidden = true
            } else {
                let properties = InputTextProperties(
                    object: Object(color, opacity, [location], "", .up),
                    inputText: "",
                    fontSize: 40.0
                )
                inputTextPropertiesSubject.send(properties)
            }
        case .pen:
            pushHistory()
            objectsSubject.value
                .append(Object(.pen, color, opacity, lineWidth, [location]))
        default:
            pushHistory()
            objectsSubject.value
                .append(Object(objectType, color, opacity, lineWidth, [location, location]))
        }
    }

    func dragMoved(
        startLocation: CGPoint,
        location: CGPoint,
        selectMovedHandler: @escaping () -> Void
    ) {
        switch objectType {
        case .select:
            selectMovedHandler()
            let diff: CGPoint = location - startLocation
            switch currentAction {
            case .none:
                break
            case .move:
                objectsSubject.send(move(diff))
            case .resize:
                objectsSubject.send(resize(diff))
            }
        case .text:
            break
        case .pen:
            let count = objects.count
            if 0 < count {
                objectsSubject.value[count - 1].points.append(location)
            }
        default:
            let count = objects.count
            if 0 < count {
                objectsSubject.value[count - 1].points[1] = location
            }
        }
    }

    func dragEnded(
        startLocation: CGPoint,
        location: CGPoint,
        selectionBounds: CGRect?,
        selectEndedHandler: @escaping () -> Void
    ) {
        switch objectType {
        case .select:
            if startLocation == location {
                // マウスを動かさなかった時はundo()
                undo()
            } else if case .rectangle = currentSelectType {
                // マウスは動かしたけれど、選択状態以外に変化が起きない時もundo()
                undo()
            }
            // 選択状態の更新
            if case .selectOne(let index) = currentSelectType {
                objectsSubject.value[index].isSelected = true
            } else if case .rectangle = currentSelectType {
                if let selectionBounds {
                    var objects_ = objects
                    for i in objects_.indices {
                        objects_[i].isSelected = objects_[i].isHit(rect: selectionBounds)
                    }
                    objectsSubject.send(objects_)
                }
            }
            currentAction = .none
            selectEndedHandler()
            lastObjects.removeAll()
        case .text:
            break
        case .pen:
            break
        default:
            if startLocation.length(from: location) < 5 {
                undo()
            }
        }
    }

    func endEditing(_ inputTextProperties: InputTextProperties) {
        let position = inputTextProperties.object.points[0]
        let inputText = inputTextProperties.inputText
        let fontSize = inputTextProperties.fontSize
        let size = inputText.calculateSize(using: NSFont.systemFont(ofSize: fontSize))
        if let index = objects.firstIndex(where: { object in
            object.type == .text && object.isHidden
        }) {
            // 既存テキスト
            objectsSubject.value[index].isHidden = false
            if inputText.isEmpty {
                pushHistory()
                objectsSubject.value.remove(at: index)
            } else {
                var object = objectsSubject.value[index]
                if inputText != object.text {
                    let endPosition = object.textOrientation.endPosition(with: position, size: size)
                    pushHistory()
                    object.points = [position, endPosition]
                    object.text = inputText
                    objectsSubject.value[index] = object
                }
            }
        } else {
            // 新規テキスト
            if !inputText.isEmpty {
                let endPosition = CGPoint(x: position.x + size.width,
                                          y: position.y + size.height)
                pushHistory()
                objectsSubject.value
                    .append(Object(color, opacity, [position, endPosition], inputText, .up))
            }
        }
        inputTextPropertiesSubject.send(nil)
    }

    // MARK: History Operation
    private func timeTravel(objects: [Object]) {
        let currentObjects = unselectedObjects()
        objectsSubject.send(objects)
        undoManager.registerUndo(withTarget: self) { target in
            target.timeTravel(objects: currentObjects)
        }
    }

    // 変化が起きる前に叩く
    private func pushHistory() {
        let objects_ = unselectedObjects()
        undoManager.registerUndo(withTarget: self) { target in
            target.timeTravel(objects: objects_)
        }
    }

    func undo() {
        if inputTextPropertiesSubject.value == nil, undoManager.canUndo {
            undoManager.undo()
        }
    }

    func redo() {
        if inputTextPropertiesSubject.value == nil, undoManager.canRedo {
            undoManager.redo()
        }
    }

    func resetHistory() {
        objectTypeSubject.send(.pen)
        objectsSubject.send([])
        let index = userDefaultsRepository.defaultColorIndex
        let properties = ObjectProperties(
            color: colors[index % 8][index / 8],
            opacity: userDefaultsRepository.defaultOpacity,
            lineWidth: userDefaultsRepository.defaultLineWidth
        )
        objectPropertiesSubject.send(properties)
        inputTextPropertiesSubject.send(nil)
        undoManager.removeAllActions()
    }

    // MARK: Operation to Selected Objects
    func updateObjectType(_ objectType: ObjectType) {
        guard self.objectType != objectType else { return }
        if self.objectType == .text,
           let inputTextProperties = inputTextPropertiesSubject.value {
            endEditing(inputTextProperties)
        }
        objectTypeSubject.send(objectType)
        guard objectType != .select else { return }
        isSelectingSubject.send(false)
        if !selectedObjects.isEmpty {
            objectsSubject.send(unselectedObjects())
        }
    }

    func updateColor(_ color: Color) {
        objectPropertiesSubject.value.color = color
        guard !selectedObjects.isEmpty else { return }
        pushHistory()
        var objects_ = objects
        for i in objects_.indices where objects_[i].isSelected {
            objects_[i].color_ = color
        }
        objectsSubject.send(objects_)
    }

    func startUpdatingOpacity() {
        guard !selectedObjects.isEmpty else { return }
        pushHistory()
    }

    func updateOpacity(_ opacity: CGFloat) {
        objectPropertiesSubject.value.opacity = opacity
        guard !selectedObjects.isEmpty else { return }
        var objects_ = objects
        for i in objects_.indices where objects_[i].isSelected {
            objects_[i].opacity = opacity
        }
        objectsSubject.send(objects_)
    }

    func startUpdatingLineWidth() {
        guard !selectedObjects.isEmpty else { return }
        pushHistory()
    }

    func updateLineWidth(_ lineWidth: CGFloat) {
        objectPropertiesSubject.value.lineWidth = lineWidth
        guard !selectedObjects.isEmpty else { return }
        var objects_ = objects
        for i in objects_.indices where objects_[i].isSelected {
            objects_[i].lineWidth = lineWidth
        }
        objectsSubject.send(objects_)
    }

    func arrange(_ arrangeMethod: ArrangeMethod) {
        guard isSelecting else { return }
        pushHistory()
        let selectedObjects_ = selectedObjects
        var objects_ = objects
        objects_.removeAll { $0.isSelected }
        switch arrangeMethod {
        case .bringToFrontmost:
            objects_.append(contentsOf: selectedObjects_)
        case .sendToBackmost:
            objects_.insert(contentsOf: selectedObjects_, at: 0)
        }
        objectsSubject.send(objects_)
    }

    func align(_ alignMethod: AlignMethod) {
        guard isSelecting, let bounds = selectedObjectsBounds else { return }
        pushHistory()
        var objects_ = objects
        for i in objects_.indices where objects_[i].isSelected {
            let diff: CGFloat
            switch alignMethod {
            case .horizontalAlignLeft:
                diff = bounds.minX - objects_[i].bounds.minX
            case .horizontalAlignCenter:
                diff = bounds.midX - objects_[i].bounds.midX
            case .horizontalAlignRight:
                diff = bounds.maxX - objects_[i].bounds.maxX
            case .verticalAlignTop:
                diff = bounds.minY - objects_[i].bounds.minY
            case .verticalAlignCenter:
                diff = bounds.midY - objects_[i].bounds.midY
            case .verticalAlignBottom:
                diff = bounds.maxY - objects_[i].bounds.maxY
            }
            for j in objects_[i].points.indices {
                if AlignMethod.horizontals.contains(alignMethod) {
                    objects_[i].points[j].x += diff
                } else {
                    objects_[i].points[j].y += diff
                }
            }
        }
        objectsSubject.send(objects_)
    }

    func flip(_ flipMethod: FlipMethod) {
        guard isSelecting, let bounds = selectedObjectsBounds else { return }
        pushHistory()
        var objects_ = objects
        for i in objects_.indices where objects_[i].isSelected {
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            objects_[i].points = objects_[i].points.map { point in
                switch flipMethod {
                case .flipHorizontal:
                    CGPoint(x: 2.0 * center.x - point.x, y: point.y)
                case .flipVertical:
                    CGPoint(x: point.x, y: 2.0 * center.y - point.y)
                }
            }
            if objects_[i].type == .text {
                objects_[i].textOrientation = objects_[i].textOrientation.flip(flipMethod)
            }
        }
        objectsSubject.send(objects_)
    }

    func rotate(_ rotateMethod: RotateMethod) {
        guard isSelecting, let bounds = selectedObjectsBounds else { return }
        pushHistory()
        let offset = CGPoint(x: bounds.origin.x + 0.5 * bounds.width,
                             y: bounds.origin.y + 0.5 * bounds.height)
        let transforms: [CGAffineTransform] = [
            .init(translationX: -offset.x, y: -offset.y),
            .init(rotationAngle: rotateMethod.angle),
            .init(translationX: offset.x, y: offset.y)
        ]
        var objects_ = objects
        for i in objects_.indices where objects_[i].isSelected {
            objects_[i].points = objects_[i].points.map { point in
                transforms.reduce(point) { partialResult, transform in
                    partialResult.applying(transform)
                }
            }
            if objects_[i].type == .text {
                objects_[i].textOrientation = objects_[i].textOrientation.rotate(rotateMethod)
            }
        }
        objectsSubject.send(objects_)
    }

    func duplicateSelectedObjects() {
        guard isSelecting else { return }
        pushHistory()
        let copyObjects = selectedObjects.map { $0.copy(needsOffset: true) }
        var objects_ = unselectedObjects()
        objects_.append(contentsOf: copyObjects)
        objectsSubject.send(objects_)
    }

    func delete() {
        guard isSelecting else { return }
        pushHistory()
        objectsSubject.value.removeAll { $0.isSelected }
    }

    func selectAll() {
        guard objectType == .select else { return }
        var objects_ = objects
        objects_.indices.forEach { i in
            objects_[i].isSelected = true
        }
        objectsSubject.send(objects_)
    }

    func clear() {
        guard inputTextPropertiesSubject.value == nil, !objects.isEmpty else {
            return
        }
        pushHistory()
        objectsSubject.send([])
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class ObjectModelMock: ObjectModel {
        let colors: [[Color]]
        var objectTypePublisher: AnyPublisher<ObjectType, Never> {
            Just(ObjectType.pen).eraseToAnyPublisher()
        }
        let objectType: ObjectType = .pen
        var objectsPublisher: AnyPublisher<[Object], Never> {
            Just([]).eraseToAnyPublisher()
        }
        var selectedObjectsBoundsPublisher: AnyPublisher<CGRect?, Never> {
            Just(nil).eraseToAnyPublisher()
        }
        var isSelectingPublisher: AnyPublisher<Bool, Never> {
            Just(false).eraseToAnyPublisher()
        }
        var objectPropertiesPublisher: AnyPublisher<ObjectProperties, Never> {
            Just(ObjectProperties(color: color, opacity: opacity, lineWidth: lineWidth)).eraseToAnyPublisher()
        }
        let color: Color
        let opacity: CGFloat = 0.8
        let lineWidth: CGFloat = 4.0
        var inputTextPropertiesPublisher: AnyPublisher<InputTextProperties?, Never> {
            Just(nil).eraseToAnyPublisher()
        }

        init(_ userDefaultsRepository: UserDefaultsRepository) {
            colors = Color.palette
            color = colors[0][0]
        }
        init() {
            colors = Color.palette
            color = colors[0][0]
        }

        func endEditing(_ inputTextProperties: InputTextProperties) {}
        func dragBegan(location: CGPoint, 
                       selectBeganHandler: @escaping () -> Void) {}
        func dragMoved(startLocation: CGPoint, 
                       location: CGPoint,
                       selectMovedHandler: @escaping () -> Void) {}
        func dragEnded(startLocation: CGPoint, 
                       location: CGPoint,
                       selectionBounds: CGRect?,
                       selectEndedHandler: @escaping () -> Void) {}

        func undo() {}
        func redo() {}
        func resetHistory() {}
        func updateObjectType(_ objectType: ObjectType) {}
        func updateColor(_ color: Color) {}
        func startUpdatingOpacity() {}
        func updateOpacity(_ opacity: CGFloat) {}
        func startUpdatingLineWidth() {}
        func updateLineWidth(_ lineWidth: CGFloat) {}
        func arrange(_ arrangeMethod: ArrangeMethod) {}
        func align(_ alignMethod: AlignMethod) {}
        func flip(_ flipMethod: FlipMethod) {}
        func rotate(_ rotateMethod: RotateMethod) {}
        func duplicateSelectedObjects() {}
        func delete() {}
        func selectAll() {}
        func clear() {}
    }
}
