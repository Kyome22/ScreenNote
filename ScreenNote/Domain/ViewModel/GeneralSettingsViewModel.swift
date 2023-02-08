/*
  GeneralSettingsViewModel.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import Foundation
import SpiceKey

protocol GeneralSettingsViewModel: ObservableObject {
    var toggleMethod: ToggleMethod { get set }
    var modifierFlag: ModifierFlag { get set }
    var toolBarPosition: ToolBarPosition { get set }
    var launchAtLogin: Bool { get set }

    init(_ userDefaultsRepository: UserDefaultsRepository,
         _ launchAtLoginRepository: LaunchAtLoginRepository)
}

final class GeneralSettingsViewModelImpl<UR: UserDefaultsRepository,
                                         LR: LaunchAtLoginRepository>: GeneralSettingsViewModel {
    @Published var toggleMethod: ToggleMethod {
        didSet { userDefaultsRepository.toggleMethod = toggleMethod }
    }
    @Published var modifierFlag: ModifierFlag {
        didSet { userDefaultsRepository.modifierFlag = modifierFlag }
    }
    @Published var toolBarPosition: ToolBarPosition {
        didSet { userDefaultsRepository.toolBarPosition = toolBarPosition }
    }
    @Published var launchAtLogin: Bool {
        didSet {
            launchAtLoginRepository.switchRegistration(launchAtLogin) { [weak self] in
                self?.launchAtLogin = oldValue
            }
        }
    }
    private let userDefaultsRepository: UR
    private let launchAtLoginRepository: LR

    init(
        _ userDefaultsRepository: UserDefaultsRepository,
        _ launchAtLoginRepository: LaunchAtLoginRepository
    ) {
        self.userDefaultsRepository = userDefaultsRepository as! UR
        self.launchAtLoginRepository = launchAtLoginRepository as! LR
        toggleMethod = userDefaultsRepository.toggleMethod
        modifierFlag = userDefaultsRepository.modifierFlag
        toolBarPosition = userDefaultsRepository.toolBarPosition
        launchAtLogin = launchAtLoginRepository.current
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class GeneralSettingsViewModelMock: GeneralSettingsViewModel {
        @Published var toggleMethod: ToggleMethod = .longPressKey
        @Published var modifierFlag: ModifierFlag = .control
        @Published var toolBarPosition: ToolBarPosition = .top
        @Published var launchAtLogin: Bool = false

        init(_ userDefaultsRepository: UserDefaultsRepository,
             _ launchAtLoginRepository: LaunchAtLoginRepository) {}
        init() {}
    }
}
