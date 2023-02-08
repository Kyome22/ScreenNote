/*
  ShortcutModel.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/31.
  
*/

import Foundation
import Combine
import SpiceKey

protocol ShortcutModel: AnyObject {
    var showOrHideCanvasPublisher: AnyPublisher<ToolBarPosition, Never> { get }

    func setShortcut()
}

final class ShortcutModelImpl<UR: UserDefaultsRepository>: ShortcutModel {
    private let showOrHideCanvasSubject = PassthroughSubject<ToolBarPosition, Never>()
    var showOrHideCanvasPublisher: AnyPublisher<ToolBarPosition, Never> {
        return showOrHideCanvasSubject.eraseToAnyPublisher()
    }

    private let userDefaultsRepository: UR
    private var spiceKey: SpiceKey?
    private var cancellables = Set<AnyCancellable>()

    init(_ userDefaultsRepository: UR) {
        self.userDefaultsRepository = userDefaultsRepository
        self.userDefaultsRepository.updateShortcutPublisher
            .sink { [weak self] in
                self?.setShortcut()
            }
            .store(in: &cancellables)
    }

    func setShortcut() {
        spiceKey?.unregister()
        let toggleMethod = userDefaultsRepository.toggleMethod
        let modifierFlag = userDefaultsRepository.modifierFlag
        switch toggleMethod {
        case .longPressKey:
            spiceKey = SpiceKey(modifierFlag.flags, 0.5, modifierKeysLongPressHandler: { [weak self] in
                guard let self else { return }
                let toolBarPosition = self.userDefaultsRepository.toolBarPosition
                self.showOrHideCanvasSubject.send(toolBarPosition)
            })
            spiceKey?.register()
        case .pressBothSideKey:
            spiceKey = SpiceKey(modifierFlag, bothModifierKeysPressHandler: { [weak self] in
                guard let self else { return }
                let toolBarPosition = self.userDefaultsRepository.toolBarPosition
                self.showOrHideCanvasSubject.send(toolBarPosition)
            })
            spiceKey?.register()
        }
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class ShortcutModelMock: ShortcutModel {
        var showOrHideCanvasPublisher: AnyPublisher<ToolBarPosition, Never> {
            Just(ToolBarPosition.top).eraseToAnyPublisher()
        }

        func setShortcut() {}
    }
}
