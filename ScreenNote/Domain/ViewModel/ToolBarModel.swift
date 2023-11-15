/*
 ToolBarModel.swift
 ScreenNote

 Created by Takuto Nakamura on 2023/11/15.
 Copyright © 2023 Studio Kyome. All rights reserved.
*/

import SwiftUI

protocol ToolBarModel: ObservableObject {
    var objectType: ObjectType { get set }
    var color: Color { get set }
    var opacity: CGFloat { get set }
    var lineWidth: CGFloat { get set }
    var showColorPopover: Bool { get set }
    var showLineWidthPopover: Bool { get set }
    var showArrangePopover: Bool { get set }
    var showAlignPopover: Bool { get set }
    var showFlipPopover: Bool { get set }
    var showRotatePopover: Bool { get set }
    var arrowEdge: Edge { get }
    var colors: [[Color]] { get }
    var disabledWhileInputingText: Bool { get }
    var disabledSelectAll: Bool { get }
    var disabledEditObject: Bool { get }

    init(objectModel: ObjectModel, arrowEdge: Edge)

    func undo()
    func redo()
    func startUpdatingOpacity()
    func startUpdatingLineWidth()
    func arrange(_ arrangeMethod: ArrangeMethod)
    func align(_ alignMethod: AlignMethod)
    func flip(_ flipMethod: FlipMethod)
    func rotate(_ rotateMethod: RotateMethod)
    func duplicateSelectedObjects()
    func delete()
    func clear()
    func selectAll()
}

final class ToolBarModelImpl: ToolBarModel {
    private let objectModel: ObjectModel

    @Published var objectType: ObjectType {
        didSet { objectModel.updateObjectType(objectType) }
    }
    @Published var color: Color {
        didSet { objectModel.updateColor(color) }
    }
    @Published var opacity: CGFloat {
        didSet { objectModel.updateOpacity(opacity) }
    }
    @Published var lineWidth: CGFloat {
        didSet { objectModel.updateLineWidth(lineWidth) }
    }
    @Published var showColorPopover: Bool = false
    @Published var showLineWidthPopover: Bool = false
    @Published var showArrangePopover: Bool = false
    @Published var showAlignPopover: Bool = false
    @Published var showFlipPopover: Bool = false
    @Published var showRotatePopover: Bool = false
    let arrowEdge: Edge
    let colors: [[Color]]
    // TODO: 更新されないかも
    var disabledWhileInputingText: Bool {
        return objectModel.objectForInputText != nil
    }
    var disabledSelectAll: Bool {
        return objectType != .select
    }
    // TODO: 更新されないかも
    var disabledEditObject: Bool {
        return !objectModel.isSelecting
    }

    init(objectModel: ObjectModel, arrowEdge: Edge) {
        self.objectModel = objectModel
        self.arrowEdge = arrowEdge
        objectType = objectModel.objectType
        color = objectModel.color
        opacity = objectModel.opacity
        lineWidth = objectModel.lineWidth
        colors = objectModel.colors
    }

    func undo() {
        objectModel.undo()
    }

    func redo() {
        objectModel.redo()
    }

    func startUpdatingOpacity() {
        objectModel.startUpdatingOpacity()
    }

    func startUpdatingLineWidth() {
        objectModel.startUpdatingLineWidth()
    }

    func arrange(_ arrangeMethod: ArrangeMethod) {
        objectModel.arrange(arrangeMethod)
    }

    func align(_ alignMethod: AlignMethod) {
        objectModel.align(alignMethod)
    }

    func flip(_ flipMethod: FlipMethod) {
        objectModel.flip(flipMethod)
    }

    func rotate(_ rotateMethod: RotateMethod) {
        objectModel.rotate(rotateMethod)
    }

    func duplicateSelectedObjects() {
        objectModel.duplicateSelectedObjects()
    }

    func delete() {
        objectModel.delete()
    }

    func clear() {
        objectModel.clear()
    }

    func selectAll() {
        objectModel.selectAll()
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class ToolBarModelMock: ToolBarModel {
        @Published var objectType: ObjectType = .pen
        @Published var color: Color = .white
        @Published var opacity: CGFloat = 0.8
        @Published var lineWidth: CGFloat = 4.0
        @Published var showColorPopover: Bool = false
        @Published var showLineWidthPopover: Bool = false
        @Published var showArrangePopover: Bool = false
        @Published var showAlignPopover: Bool = false
        @Published var showFlipPopover: Bool = false
        @Published var showRotatePopover: Bool = false
        let arrowEdge: Edge = .bottom
        let colors: [[Color]] = []
        let disabledWhileInputingText: Bool = false
        let disabledSelectAll: Bool = false
        let disabledEditObject: Bool = false

        init(objectModel: ObjectModel, arrowEdge: Edge) {}
        init() {}

        func undo() {}
        func redo() {}
        func startUpdatingOpacity() {}
        func startUpdatingLineWidth() {}
        func arrange(_ arrangeMethod: ArrangeMethod) {}
        func align(_ alignMethod: AlignMethod) {}
        func flip(_ flipMethod: FlipMethod) {}
        func rotate(_ rotateMethod: RotateMethod) {}
        func duplicateSelectedObjects() {}
        func delete() {}
        func clear() {}
        func selectAll() {}
    }
}
