/*
 CanvasViewModel.swift
 ScreenNote

 Created by Takuto Nakamura on 2023/11/16.
 Copyright © 2023 Studio Kyome. All rights reserved.
*/

import SwiftUI

protocol CanvasViewModel: ObservableObject {
    var rectangleForSelection: Object? { get set }
    var selectedObjectsBounds: CGRect? { get set }
    var objects: [Object] { get set }
    var color: Color { get set }
    var opacity: CGFloat { get set }
    var lineWidth: CGFloat { get set }
    var objectForInputText: Object? { get set }
    var inputText: String { get set }
    var fontSize: CGFloat { get set }
    var dragging: Bool { get set }

    init(objectModel: ObjectModel)

    func dragBegan(location: CGPoint)
    func dragMoved(startLocation: CGPoint, location: CGPoint)
    func dragEnded(startLocation: CGPoint, location: CGPoint)
    func endEditing(_ textObject: Object)
}

final class CanvasViewModelImpl: CanvasViewModel {
    private let objectModel: ObjectModel

    @Published var rectangleForSelection: Object?
    @Published var selectedObjectsBounds: CGRect?
    @Published var objects = [Object]()
    @Published var color: Color
    @Published var opacity: CGFloat
    @Published var lineWidth: CGFloat
    @Published var objectForInputText: Object?
    @Published var inputText: String = ""
    @Published var fontSize: CGFloat
    @Published var dragging: Bool = false

    init(objectModel: ObjectModel) {
        self.objectModel = objectModel
        color = objectModel.color
        opacity = objectModel.opacity
        lineWidth = objectModel.lineWidth
        fontSize = objectModel.fontSize
    }

    func dragBegan(location: CGPoint) {
        objectModel.dragBegan(location: location)
    }

    func dragMoved(startLocation: CGPoint, location: CGPoint) {
        objectModel.dragMoved(startLocation: startLocation, location: location)
    }

    func dragEnded(startLocation: CGPoint, location: CGPoint) {
        objectModel.dragEnded(startLocation: startLocation, location: location)
    }

    func endEditing(_ textObject: Object) {
        objectModel.endEditing(textObject)
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class CanvasViewModelMock: CanvasViewModel {
        @Published var rectangleForSelection: Object?
        @Published var selectedObjectsBounds: CGRect?
        @Published var objects = [Object]()
        @Published var color: Color = .white
        @Published var opacity: CGFloat = 0.8
        @Published var lineWidth: CGFloat = 4.0
        @Published var objectForInputText: Object?
        @Published var inputText: String = ""
        @Published var fontSize: CGFloat = 40.0
        @Published var dragging: Bool = false

        init(objectModel: ObjectModel) {}
        init() {}

        func dragBegan(location: CGPoint) {}
        func dragMoved(startLocation: CGPoint, location: CGPoint) {}
        func dragEnded(startLocation: CGPoint, location: CGPoint) {}
        func endEditing(_ textObject: Object) {}
    }
}
