/*
 ToolBarModel.swift
 ScreenNote

 Created by Takuto Nakamura on 2023/11/15.
 Copyright © 2023 Studio Kyome. All rights reserved.
*/

import SwiftUI
import Combine

protocol ToolBarModel: ObservableObject {
    var objectType: ObjectType { get set }
    var color: Color { get set }
    var opacity: CGFloat { get set }
    var lineWidth: CGFloat { get set }
    var disabledWhileInputingText: Bool { get set }
    var disabledSelectAll: Bool { get set }
    var disabledEditObject: Bool { get set }
    var showColorPopover: Bool { get set }
    var showLineWidthPopover: Bool { get set }
    var showArrangePopover: Bool { get set }
    var showAlignPopover: Bool { get set }
    var showFlipPopover: Bool { get set }
    var showRotatePopover: Bool { get set }
    var arrowEdge: Edge { get }
    var colors: [[Color]] { get }

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
    func updateObjectType(_ objectType: ObjectType)
    func updateColor(_ color: Color)
    func updateOpacity(_ opacity: CGFloat)
    func updateLineWidth(_ lineWidth: CGFloat)
}

final class ToolBarModelImpl: ToolBarModel {
    private let objectModel: ObjectModel
    private var cancellables = Set<AnyCancellable>()

    @Published var objectType: ObjectType
    @Published var color: Color
    @Published var opacity: CGFloat
    @Published var lineWidth: CGFloat
    @Published var disabledWhileInputingText: Bool = false
    @Published var disabledSelectAll: Bool = false
    @Published var disabledEditObject: Bool = false
    @Published var showColorPopover: Bool = false
    @Published var showLineWidthPopover: Bool = false
    @Published var showArrangePopover: Bool = false
    @Published var showAlignPopover: Bool = false
    @Published var showFlipPopover: Bool = false
    @Published var showRotatePopover: Bool = false
    let arrowEdge: Edge
    let colors: [[Color]]

    init(objectModel: ObjectModel, arrowEdge: Edge) {
        self.objectModel = objectModel
        self.arrowEdge = arrowEdge
        objectType = objectModel.objectType
        color = objectModel.color
        opacity = objectModel.opacity
        lineWidth = objectModel.lineWidth
        colors = objectModel.colors

        objectModel.objectTypePublisher
            .sink { [weak self] objectType in
                self?.objectType = objectType
            }
            .store(in: &cancellables)

        objectModel.isSelectingPublisher
            .sink { [weak self] isSelecting in
                self?.disabledEditObject = !isSelecting
            }
            .store(in: &cancellables)

        objectModel.objectPropertiesPublisher
            .sink { [weak self] properties in
                self?.color = properties.color
                self?.opacity = properties.opacity
                self?.lineWidth = properties.lineWidth
            }
            .store(in: &cancellables)

        objectModel.inputTextPropertiesPublisher
            .sink { [weak self] properties in
                self?.disabledWhileInputingText = (properties != nil)
            }
            .store(in: &cancellables)
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

    func updateObjectType(_ objectType: ObjectType) {
        objectModel.updateObjectType(objectType)
    }

    func updateColor(_ color: Color) {
        objectModel.updateColor(color)
    }

    func updateOpacity(_ opacity: CGFloat) {
        objectModel.updateOpacity(opacity)
    }

    func updateLineWidth(_ lineWidth: CGFloat) {
        objectModel.updateLineWidth(lineWidth)
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class ToolBarModelMock: ToolBarModel {
        @Published var objectType: ObjectType = .pen
        @Published var color: Color = .white
        @Published var opacity: CGFloat = 0.8
        @Published var lineWidth: CGFloat = 4.0
        @Published var disabledWhileInputingText: Bool = false
        @Published var disabledSelectAll: Bool = false
        @Published var disabledEditObject: Bool = false
        @Published var showColorPopover: Bool = false
        @Published var showLineWidthPopover: Bool = false
        @Published var showArrangePopover: Bool = false
        @Published var showAlignPopover: Bool = false
        @Published var showFlipPopover: Bool = false
        @Published var showRotatePopover: Bool = false
        let arrowEdge: Edge = .bottom
        let colors: [[Color]] = []

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
        func updateObjectType(_ objectType: ObjectType) {}
        func updateColor(_ color: Color) {}
        func updateOpacity(_ opacity: CGFloat) {}
        func updateLineWidth(_ lineWidth: CGFloat) {}
    }
}
