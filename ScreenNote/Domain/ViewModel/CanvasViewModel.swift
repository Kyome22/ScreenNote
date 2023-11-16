/*
 CanvasViewModel.swift
 ScreenNote

 Created by Takuto Nakamura on 2023/11/16.
 Copyright © 2023 Studio Kyome. All rights reserved.
*/

import SwiftUI
import Combine

protocol CanvasViewModel: ObservableObject {
    var selectedObjectsBounds: CGRect? { get set }
    var objects: [Object] { get set }
    var inputTextProperties: InputTextProperties? { get set }
    var inputText: String { get set }
    var textColor: Color { get set }
    var dragging: Bool { get set }
    var rectangleForSelection: Object? { get set }

    init(objectModel: ObjectModel)

    func dragBegan(location: CGPoint)
    func dragMoved(startLocation: CGPoint, location: CGPoint)
    func dragEnded(startLocation: CGPoint, location: CGPoint)
    func endEditing(inputTextObject: Object, fontSize: CGFloat)
}

final class CanvasViewModelImpl: CanvasViewModel {
    private let objectModel: ObjectModel
    private var lineWidth: CGFloat = 0.8
    private var cancellables = Set<AnyCancellable>()

    @Published var objects = [Object]()
    @Published var inputTextProperties: InputTextProperties?
    @Published var inputText: String = ""
    @Published var textColor: Color
    @Published var dragging: Bool = false
    @Published var selectedObjectsBounds: CGRect?
    @Published var rectangleForSelection: Object?

    init(objectModel: ObjectModel) {
        self.objectModel = objectModel
        textColor = objectModel.color.opacity(objectModel.opacity)

        objectModel.objectsPublisher
            .sink { [weak self] objects in
                self?.objects = objects
            }
            .store(in: &cancellables)

        objectModel.selectedObjectsBoundsPublisher
            .sink { [weak self] bounds in
                self?.selectedObjectsBounds = bounds
            }
            .store(in: &cancellables)

        objectModel.objectPropertiesPublisher
            .sink { [weak self] properties in
                self?.textColor = properties.color.opacity(properties.opacity)
                self?.lineWidth = properties.lineWidth
            }
            .store(in: &cancellables)

        objectModel.inputTextPropertiesPublisher
            .sink { [weak self] properties in
                self?.inputTextProperties = properties
            }
            .store(in: &cancellables)
    }

    func dragBegan(location: CGPoint) {
        objectModel.dragBegan(location: location) { [weak self] in
            guard let self else { return }
            rectangleForSelection = Object(.select, .black, 1.0, lineWidth, [location, location])
        }
    }

    func dragMoved(startLocation: CGPoint, location: CGPoint) {
        objectModel.dragMoved(
            startLocation: startLocation,
            location: location
        ) { [weak self] in
            self?.rectangleForSelection?.points[1] = location
        }
    }

    func dragEnded(startLocation: CGPoint, location: CGPoint) {
        objectModel.dragEnded(
            startLocation: startLocation,
            location: location,
            selectionBounds: rectangleForSelection?.bounds
        ) { [weak self] in
            self?.rectangleForSelection = nil
        }
    }

    func endEditing(inputTextObject: Object, fontSize: CGFloat) {
        objectModel.endEditing(InputTextProperties(
            object: inputTextObject,
            inputText: inputText,
            fontSize: fontSize
        ))
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class CanvasViewModelMock: CanvasViewModel {
        @Published var selectedObjectsBounds: CGRect?

        @Published var objects = [Object]()
        @Published var inputTextProperties: InputTextProperties?
        @Published var inputText: String = ""
        @Published var textColor: Color = .white
        @Published var dragging: Bool = false
        @Published var rectangleForSelection: Object?

        init(objectModel: ObjectModel) {}
        init() {}

        func dragBegan(location: CGPoint) {}
        func dragMoved(startLocation: CGPoint, location: CGPoint) {}
        func dragEnded(startLocation: CGPoint, location: CGPoint) {}
        func endEditing(inputTextObject: Object, fontSize: CGFloat) {}
    }
}
