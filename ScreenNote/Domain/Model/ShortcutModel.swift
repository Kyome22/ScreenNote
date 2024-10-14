/*
  ShortcutModel.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/31.
  
*/

import Combine
import Foundation
import SpiceKey

protocol ShortcutModel: AnyObject {
    var showOrHideCanvasPublisher: AnyPublisher<Void, Never> { get }

    init(_ userDefaultsRepository: UserDefaultsRepository)

    func setShortcut()
}

final class ShortcutModelImpl: ShortcutModel {
    private let showOrHideCanvasSubject = PassthroughSubject<Void, Never>()
    var showOrHideCanvasPublisher: AnyPublisher<Void, Never> {
        showOrHideCanvasSubject.eraseToAnyPublisher()
    }

    private let userDefaultsRepository: UserDefaultsRepository
    private var spiceKey: SpiceKey?
    private var cancellables = Set<AnyCancellable>()

    init(_ userDefaultsRepository: UserDefaultsRepository) {
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
        let longPressSeconds = userDefaultsRepository.longPressSeconds
        switch toggleMethod {
        case .longPressKey:
            spiceKey = SpiceKey(modifierFlag.flags, longPressSeconds, modifierKeysLongPressHandler: { [weak self] in
                self?.showOrHideCanvasSubject.send()
            })
            spiceKey?.register()
        case .pressBothSideKeys:
            spiceKey = SpiceKey(modifierFlag, bothModifierKeysPressHandler: { [weak self] in
                self?.showOrHideCanvasSubject.send()
            })
            spiceKey?.register()
        }
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class ShortcutModelMock: ShortcutModel {
        var showOrHideCanvasPublisher: AnyPublisher<Void, Never> {
            Just(()).eraseToAnyPublisher()
        }

        init(_ userDefaultsRepository: UserDefaultsRepository) {}
        init() {}

        func setShortcut() {}
    }
}
