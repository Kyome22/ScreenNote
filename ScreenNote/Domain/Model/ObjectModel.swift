/*
  ObjectModel.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SwiftUI

protocol ObjectModel: AnyObject {
    var objectType: ObjectType { get }
    var rectangleForSelection: Object? { get }
    var selectedObjectsBounds: CGRect? { get }
    var objects: [Object] { get }
    var color: Color { get }
    var opacity: CGFloat { get }
    var lineWidth: CGFloat { get }
    var objectForInputText: Object? { get }
    var inputText: String { get }
    var fontSize: CGFloat { get }
    var isSelecting: Bool { get }
    var colors: [[Color]] { get }

    init(_ userDefaultsRepository: UserDefaultsRepository)

    func endEditing(_ textObject: Object)
    func dragBegan(location: CGPoint)
    func dragMoved(startLocation: CGPoint, location: CGPoint)
    func dragEnded(startLocation: CGPoint, location: CGPoint)

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

    var objectType: ObjectType = .pen
    var rectangleForSelection: Object?
    var selectedObjectsBounds: CGRect?
    var objects = [Object]()
    var color: Color
    var opacity: CGFloat
    var lineWidth: CGFloat
    var objectForInputText: Object?
    var inputText: String = ""
    var fontSize: CGFloat = 40.0
    var isSelecting: Bool = false
    let colors: [[Color]]

    private let userDefaultsRepository: UserDefaultsRepository
    private let undoManager = UndoManager()
    private var lastObjects = [Object]()
    private var currentAction: Action = .none
    private var currentAnchor: Anchor = .topLeft
    private var currentSelectType: SelectType = .rectangle

    private var selectedObjects: [Object] {
        return objects.filter { $0.isSelected }
    }

    init(_ userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
        colors = Color.palette
        let index = userDefaultsRepository.defaultColorIndex
        color = colors[index % 8][index / 8]
        opacity = userDefaultsRepository.defaultOpacity
        lineWidth = userDefaultsRepository.defaultLineWidth
        undoManager.levelsOfUndo = 15
    }

    private func unselectAllObjects() {
        for i in (0 ..< objects.count) where objects[i].isSelected {
            objects[i].isSelected = false
        }
    }

    private func objectsBounds(_ objects: [Object]) -> CGRect? {
        return objects.reduce(CGRect?.none) { partialResult, object in
            return partialResult?.union(object.bounds) ?? object.bounds
        }
    }

    private func updatedObjects() {
        selectedObjectsBounds = objectsBounds(selectedObjects)
        isSelecting = (objectType == .select && selectedObjectsBounds != nil)
    }

    private func hitAnchor(_ point: CGPoint) -> Anchor? {
        guard let bounds = objectsBounds(selectedObjects) else { return nil }
        let anchors = Path.anchorPaths(bounds: bounds)
        return zip(anchors, Anchor.allCases)
            .first { $0.0.contains(point) }?.1
    }

    private func move(_ diff: CGPoint) -> [Object] {
        return lastObjects.map { object in
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
                return transforms.reduce(point) { partialResult, transform in
                    partialResult.applying(transform)
                }
            }
            return copyObject
        }
    }

    func dragBegan(location: CGPoint) {
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
                unselectAllObjects()
                objects[index].isSelected = true
            } else {
                currentSelectType = .rectangle
                currentAction = .none
                unselectAllObjects()
                rectangleForSelection = Object(.select, .black, 1.0, lineWidth, [location, location])
            }
            lastObjects = objects
        case .text:
            if let textObject = objectForInputText {
                endEditing(textObject)
            }
            if let index = objects.lastIndex(where: { object in
                object.type == .text && object.isHit(point: location)
            }) {
                objectForInputText = objects[index]
                inputText = objects[index].text
                fontSize = objects[index].fontSize
                objects[index].isHidden = true
            } else {
                objectForInputText = Object(color, opacity, [location], "", .up)
                inputText = ""
                fontSize = 40.0
            }
        case .pen:
            pushHistory()
            objects.append(
                Object(.pen, color, opacity, lineWidth, [location])
            )
        default:
            pushHistory()
            objects.append(
                Object(objectType, color, opacity, lineWidth, [location, location])
            )
        }
    }

    func dragMoved(startLocation: CGPoint, location: CGPoint) {
        switch objectType {
        case .select:
            rectangleForSelection?.points[1] = location
            let diff: CGPoint = location - startLocation
            switch currentAction {
            case .none:
                break
            case .move:
                objects = move(diff)
            case .resize:
                objects = resize(diff)
            }
        case .text:
            break
        case .pen:
            if objects.isEmpty { break }
            objects[objects.count - 1].points.append(location)
        default:
            if objects.isEmpty { break }
            objects[objects.count - 1].points[1] = location
        }
    }

    func dragEnded(startLocation: CGPoint, location: CGPoint) {
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
                objects[index].isSelected = true
            } else if case .rectangle = currentSelectType {
                if let rectangleForSelection {
                    let bounds = rectangleForSelection.bounds
                    for i in (0 ..< objects.count) {
                        objects[i].isSelected = objects[i].isHit(rect: bounds)
                    }
                }
            }
            currentAction = .none
            rectangleForSelection = nil
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

    func endEditing(_ textObject: Object) {
        let position = textObject.points[0]
        let size = inputText.calculateSize(using: NSFont.systemFont(ofSize: fontSize))
        if let index = objects.firstIndex(where: { object in
            object.type == .text && object.isHidden
        }) {
            // 既存テキスト
            objects[index].isHidden = false
            if inputText.isEmpty {
                pushHistory()
                objects.remove(at: index)
            } else if inputText != objects[index].text {
                let endPosition = objects[index].textOrientation.endPosition(with: position, size: size)
                pushHistory()
                objects[index].points = [position, endPosition]
                objects[index].text = inputText
            }
        } else {
            // 新規テキスト
            if !inputText.isEmpty {
                let endPosition = CGPoint(x: position.x + size.width,
                                          y: position.y + size.height)
                pushHistory()
                objects.append(
                    Object(color, opacity, [position, endPosition], inputText, .up)
                )
            }
        }
        objectForInputText = nil
        inputText = ""
        fontSize = 40.0
    }

    // MARK: History Operation
    private func timeTravel(objects: [Object]) {
        let currentObjects = self.objects
        self.objects = objects
        unselectAllObjects()
        undoManager.registerUndo(withTarget: self) { target in
            target.timeTravel(objects: currentObjects)
        }
    }

    // 変化が起きる前に叩く
    private func pushHistory() {
        undoManager.registerUndo(withTarget: self) { [objects] target in
            target.timeTravel(objects: objects)
        }
    }

    func undo() {
        if objectForInputText == nil, undoManager.canUndo {
            undoManager.undo()
        }
    }

    func redo() {
        if objectForInputText == nil, undoManager.canRedo {
            undoManager.redo()
        }
    }

    func resetHistory() {
        objectType = .pen
        objects.removeAll()
        let index = userDefaultsRepository.defaultColorIndex
        color = colors[index % 8][index / 8]
        opacity = userDefaultsRepository.defaultOpacity
        lineWidth = userDefaultsRepository.defaultLineWidth
        objectForInputText = nil
        inputText = ""
        fontSize = 40.0
        undoManager.removeAllActions()
    }

    // MARK: Operation to Selected Objects
    func updateObjectType(_ objectType: ObjectType) {
        if self.objectType == objectType { return }
        if self.objectType == .text, let textObject = objectForInputText {
            endEditing(textObject)
        }
        self.objectType = objectType
        if objectType == .select { return }
        isSelecting = false
        if !selectedObjects.isEmpty {
            unselectAllObjects()
        }
    }

    // TODO: 変更を通知したいかどうかで実装が変わりそう
    func updateColor(_ color: Color) {
        self.color = color
        if selectedObjects.isEmpty { return }
        pushHistory()
        for i in (0 ..< objects.count) where objects[i].isSelected {
            objects[i].color_ = color
        }
    }

    func startUpdatingOpacity() {
        if selectedObjects.isEmpty { return }
        pushHistory()
    }

    func updateOpacity(_ opacity: CGFloat) {
        self.opacity = opacity
        if selectedObjects.isEmpty { return }
        for i in (0 ..< objects.count) where objects[i].isSelected {
            objects[i].opacity = opacity
        }
    }

    func startUpdatingLineWidth() {
        if selectedObjects.isEmpty { return }
        pushHistory()
    }

    func updateLineWidth(_ lineWidth: CGFloat) {
        self.lineWidth = lineWidth
        if selectedObjects.isEmpty { return }
        for i in (0 ..< objects.count) where objects[i].isSelected {
            objects[i].lineWidth = lineWidth
        }
    }

    func arrange(_ arrangeMethod: ArrangeMethod) {
        guard isSelecting else { return }
        let targetObjects = selectedObjects
        pushHistory()
        objects.removeAll { $0.isSelected }
        switch arrangeMethod {
        case .bringToFrontmost:
            objects.append(contentsOf: targetObjects)
        case .sendToBackmost:
            objects.insert(contentsOf: targetObjects, at: 0)
        }
    }

    func align(_ alignMethod: AlignMethod) {
        guard isSelecting, let bounds = selectedObjectsBounds else { return }
        pushHistory()
        for i in (0 ..< objects.count) where objects[i].isSelected {
            let diff: CGFloat
            switch alignMethod {
            case .horizontalAlignLeft:
                diff = bounds.minX - objects[i].bounds.minX
            case .horizontalAlignCenter:
                diff = bounds.midX - objects[i].bounds.midX
            case .horizontalAlignRight:
                diff = bounds.maxX - objects[i].bounds.maxX
            case .verticalAlignTop:
                diff = bounds.minY - objects[i].bounds.minY
            case .verticalAlignCenter:
                diff = bounds.midY - objects[i].bounds.midY
            case .verticalAlignBottom:
                diff = bounds.maxY - objects[i].bounds.maxY
            }
            for j in (0 ..< objects[i].points.count) {
                if AlignMethod.horizontals.contains(alignMethod) {
                    objects[i].points[j].x += diff
                } else {
                    objects[i].points[j].y += diff
                }
            }
        }
    }

    func flip(_ flipMethod: FlipMethod) {
        guard isSelecting, let bounds = selectedObjectsBounds else { return }
        pushHistory()
        for i in (0 ..< objects.count) where objects[i].isSelected {
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            objects[i].points = objects[i].points.map { point in
                switch flipMethod {
                case .flipHorizontal:
                    return CGPoint(x: 2.0 * center.x - point.x, y: point.y)
                case .flipVertical:
                    return CGPoint(x: point.x, y: 2.0 * center.y - point.y)
                }
            }
            if objects[i].type == .text {
                objects[i].textOrientation = objects[i].textOrientation.flip(flipMethod)
            }
        }
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
        for i in (0 ..< objects.count) where objects[i].isSelected {
            objects[i].points = objects[i].points.map { point in
                return transforms.reduce(point) { partialResult, transform in
                    partialResult.applying(transform)
                }
            }
            if objects[i].type == .text {
                objects[i].textOrientation = objects[i].textOrientation.rotate(rotateMethod)
            }
        }
    }

    func duplicateSelectedObjects() {
        guard isSelecting else { return }
        var targetObjects = selectedObjects
        pushHistory()
        unselectAllObjects()
        targetObjects = targetObjects.map { $0.copy(needsOffset: true) }
        objects.append(contentsOf: targetObjects)
    }

    func delete() {
        guard isSelecting else { return }
        pushHistory()
        objects.removeAll { $0.isSelected }
    }

    func selectAll() {
        guard objectType == .select else { return }
        for i in (0 ..< objects.count) {
            objects[i].isSelected = true
        }
    }

    func clear() {
        if objectForInputText == nil, !objects.isEmpty {
            pushHistory()
            objects.removeAll()
        }
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class ObjectModelMock: ObjectModel {
        var objectType: ObjectType = .select
        var rectangleForSelection: Object?
        var selectedObjectsBounds: CGRect?
        var objects: [Object] = []
        var color: Color
        var opacity: CGFloat = 0.8
        var lineWidth: CGFloat = 4.0
        var objectForInputText: Object?
        var inputText: String = ""
        var fontSize: CGFloat = 40.0
        var isSelecting: Bool = false
        let colors: [[Color]]

        init(_ userDefaultsRepository: UserDefaultsRepository) {
            colors = Color.palette
            color = colors[0][0]
        }
        init() {
            colors = Color.palette
            color = colors[0][0]
        }

        func endEditing(_ textObject: Object) {}
        func dragBegan(location: CGPoint) {}
        func dragMoved(startLocation: CGPoint, location: CGPoint) {}
        func dragEnded(startLocation: CGPoint, location: CGPoint) {}

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
