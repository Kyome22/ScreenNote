/*
  ObjectModel.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import SwiftUI

protocol ObjectModel: ObservableObject {
    var objectType: ObjectType { get set }
    var rectangleForSelection: Object? { get set }
    var selectedObjectsBounds: CGRect? { get set }
    var objects: [Object] { get set }
    var color: Color { get set }
    var alpha: CGFloat { get set }
    var lineWidth: CGFloat { get set }
    var textFieldPosition: CGPoint? { get set }
    var inputText: String { get set }
    var fontSize: CGFloat { get set }
    var colors: [[Color]] { get }

    func endEditing(position: CGPoint)
    func dragBegan(location: CGPoint)
    func dragMoved(startLocation: CGPoint, location: CGPoint)
    func dragEnded(startLocation: CGPoint, location: CGPoint)

    func undo()
    func redo()
    func willUpdateAlpha()
    func willUpdateLineWidth()
    func arrange(_ arrangeMethod: ObjectArrangeMethod)
    func align(_ alignment: ObjectAlignment)
    func flip(_ flipDirection: ObjectFlipDirection)
    func rotate(_ rotateDirection: ObjectRotateDirection)
    func duplicateSelectedObjects()
    func delete()
    func selectAll()
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

    @Published var objectType: ObjectType = .select {
        didSet { updatedObjectType(oldValue) }
    }
    @Published var rectangleForSelection: Object?
    @Published var selectedObjectsBounds: CGRect?
    @Published var objects = [Object]() {
        didSet { updateSelectedObjectsBounds() }
    }
    @Published var color: Color = Color.clear {
        didSet { updatedColor(oldValue) }
    }
    @Published var alpha: CGFloat = 0.8 {
        didSet { updatedAlpha() }
    }
    @Published var lineWidth: CGFloat = 4.0 {
        didSet { updatedLineWidth() }
    }
    @Published var textFieldPosition: CGPoint?
    @Published var inputText: String = ""
    @Published var fontSize: CGFloat = 40.0

    let colors: [[Color]]

    private let undoManager = UndoManager()
    private var lastObjects = [Object]()
    private var currentAction: Action = .none
    private var currentAnchor: Anchor = .topLeft
    private var currentSelectType: SelectType = .rectangle

    private var selectedObjects: [Object] {
        return objects.filter { $0.isSelected }
    }

    init() {
        let primaries: [NSColor] = [
            NSColor(named: "UniqueWhite")!,
            NSColor(named: "UniqueRed")!,
            NSColor(named: "UniqueOrange")!,
            NSColor(named: "UniqueYello")!,
            NSColor(named: "UniqueGreen")!,
            NSColor(named: "UniqueBlue")!,
            NSColor(named: "UniqueViolet")!,
            NSColor(named: "UniquePurple")!
        ]
        colors = primaries.map { primary in
            return (0 ..< 5).map { i in
                Color(primary.blended(withFraction: 0.2 * CGFloat(i), of: .black)!)
            }
        }
        color = colors[0][0]
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

    private func updateSelectedObjectsBounds() {
        selectedObjectsBounds = objectsBounds(selectedObjects)
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
        // リファクタリング禁止
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
            if let position = textFieldPosition {
                endEditing(position: position)
            }
            if let index = objects.lastIndex(where: { object in
                object.type == .text && object.isHit(point: location)
            }) {
                textFieldPosition = objects[index].points[0]
                inputText = objects[index].text
                fontSize = objects[index].fontSize
                objects[index].isHidden = true
            } else {
                textFieldPosition = location
                inputText = ""
                fontSize = 40.0
            }
        case .pen:
            pushHistory()
            objects.append(
                Object(.pen, color, alpha, lineWidth, [location])
            )
        default:
            pushHistory()
            objects.append(
                Object(objectType, color, alpha, lineWidth, [location, location])
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
                    for i in (0 ..< objects.count) {
                        objects[i].isSelected = objects[i].isHit(rect: rectangleForSelection.bounds)
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

    func endEditing(position: CGPoint) {
        let size = inputText.calculateSize(using: NSFont.systemFont(ofSize: fontSize))
        let endPosition = CGPoint(x: position.x + size.width,
                                  y: position.y + size.height)
        if let index = objects.firstIndex(where: { object in
            object.type == .text && object.isHidden
        }) {
            // 既存テキスト
            objects[index].isHidden = false
            if inputText.isEmpty {
                pushHistory()
                objects.remove(at: index)
            } else if inputText != objects[index].text {
                pushHistory()
                objects[index].points = [position, endPosition]
                objects[index].text = inputText
            }
        } else {
            // 新規テキスト
            if !inputText.isEmpty {
                pushHistory()
                objects.append(
                    Object(color, alpha, [position, endPosition], inputText)
                )
            }
        }
        textFieldPosition = nil
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
        if objectType == .text { return }
        if undoManager.canUndo {
            undoManager.undo()
        }
    }

    func redo() {
        if objectType == .text { return }
        if undoManager.canRedo {
            undoManager.redo()
        }
    }

    // MARK: Operation to Selected Objects
    private func updatedObjectType(_ oldValue: ObjectType) {
        if objectType == oldValue { return }
        if oldValue == .text, let position = textFieldPosition {
            endEditing(position: position)
        }
        if objectType != .select, !selectedObjects.isEmpty {
            unselectAllObjects()
        }
    }

    private func updatedColor(_ oldValue: Color) {
        if color == oldValue || selectedObjects.isEmpty { return }
        pushHistory()
        for i in (0 ..< objects.count) where objects[i].isSelected {
            objects[i].color_ = color
        }
    }

    func willUpdateAlpha() {
        if selectedObjects.isEmpty { return }
        pushHistory()
    }

    private func updatedAlpha() {
        if selectedObjects.isEmpty { return }
        for i in (0 ..< objects.count) where objects[i].isSelected {
            objects[i].alpha = alpha
        }
    }

    func willUpdateLineWidth() {
        if selectedObjects.isEmpty { return }
        pushHistory()
    }

    private func updatedLineWidth() {
        if selectedObjects.isEmpty { return }
        for i in (0 ..< objects.count) where objects[i].isSelected {
            objects[i].lineWidth = lineWidth
        }
    }

    func arrange(_ arrangeMethod: ObjectArrangeMethod) {
        guard objectType == .select else { return }
        let targetObjects = selectedObjects
        if targetObjects.isEmpty { return }
        pushHistory()
        objects.removeAll { $0.isSelected }
        switch arrangeMethod {
        case .bringToFrontmost:
            objects.append(contentsOf: targetObjects)
        case .sendToBackmost:
            objects.insert(contentsOf: targetObjects, at: 0)
        }
    }

    func align(_ alignment: ObjectAlignment) {
        guard objectType == .select, let bounds = selectedObjectsBounds else { return }
        pushHistory()
        for i in (0 ..< objects.count) where objects[i].isSelected {
            let diff: CGFloat
            switch alignment {
            case .left:
                diff = bounds.minX - objects[i].bounds.minX
            case .hCenter:
                diff = bounds.midX - objects[i].bounds.midX
            case .right:
                diff = bounds.maxX - objects[i].bounds.maxX
            case .top:
                diff = bounds.minY - objects[i].bounds.minY
            case .vCenter:
                diff = bounds.midY - objects[i].bounds.midY
            case .bottom:
                diff = bounds.maxY - objects[i].bounds.maxY
            }
            for j in (0 ..< objects[i].points.count) {
                switch alignment {
                case .top, .vCenter, .bottom:
                    objects[i].points[j].y += diff
                case .left, .hCenter, .right:
                    objects[i].points[j].x += diff
                }
            }
        }
    }

    func flip(_ flipDirection: ObjectFlipDirection) {
        guard objectType == .select, let bounds = selectedObjectsBounds else { return }
        pushHistory()
        for i in (0 ..< objects.count) where objects[i].isSelected {
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            objects[i].points = objects[i].points.map { point in
                switch flipDirection {
                case .horizontal:
                    return CGPoint(x: 2.0 * center.x - point.x, y: point.y)
                case .vertical:
                    return CGPoint(x: point.x, y: 2.0 * center.y - point.y)
                }
            }
        }
    }

    func rotate(_ rotateDirection: ObjectRotateDirection) {
        guard objectType == .select, let bounds = selectedObjectsBounds else { return }
        pushHistory()
        let offset = CGPoint(x: bounds.origin.x + 0.5 * bounds.width,
                             y: bounds.origin.y + 0.5 * bounds.height)
        let transforms: [CGAffineTransform] = [
            .init(translationX: -offset.x, y: -offset.y),
            .init(rotationAngle: rotateDirection.angle),
            .init(translationX: offset.x, y: offset.y)
        ]
        for i in (0 ..< objects.count) where objects[i].isSelected {
            objects[i].points = objects[i].points.map { point in
                return transforms.reduce(point) { partialResult, transform in
                    partialResult.applying(transform)
                }
            }
        }
    }

    func duplicateSelectedObjects() {
        guard objectType == .select else { return }
        var targetObjects = selectedObjects
        if targetObjects.isEmpty { return }
        pushHistory()
        unselectAllObjects()
        targetObjects = targetObjects.map { $0.copy(needsOffset: true) }
        objects.append(contentsOf: targetObjects)
    }

    func delete() {
        guard objectType == .select, !selectedObjects.isEmpty else { return }
        pushHistory()
        objects.removeAll { $0.isSelected }
    }

    func selectAll() {
        guard objectType == .select else { return }
        for i in (0 ..< objects.count) {
            objects[i].isSelected = true
        }
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class ObjectModelMock: ObjectModel {
        @Published var objectType: ObjectType = .select
        @Published var rectangleForSelection: Object?
        @Published var selectedObjectsBounds: CGRect?
        @Published var objects: [Object] = []
        @Published var color: Color = Color("UniqueRed")
        @Published var alpha: CGFloat = 0.8
        @Published var lineWidth: CGFloat = 4.0
        @Published var textFieldPosition: CGPoint?
        @Published var inputText: String = ""
        @Published var fontSize: CGFloat = 40.0

        var colors: [[Color]] = []

        init() {}

        func endEditing(position: CGPoint) {}
        func dragBegan(location: CGPoint) {}
        func dragMoved(startLocation: CGPoint, location: CGPoint) {}
        func dragEnded(startLocation: CGPoint, location: CGPoint) {}

        func undo() {}
        func redo() {}
        func willUpdateAlpha() {}
        func willUpdateLineWidth() {}
        func arrange(_ arrangeMethod: ObjectArrangeMethod) {}
        func align(_ alignment: ObjectAlignment) {}
        func flip(_ flipDirection: ObjectFlipDirection) {}
        func rotate(_ rotateDirection: ObjectRotateDirection) {}
        func duplicateSelectedObjects() {}
        func delete() {}
        func selectAll() {}
    }
}
