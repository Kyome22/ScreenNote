/*
  ScreenNoteAppModel.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import AppKit
import Combine
import SpiceKey

protocol ScreenNoteAppModel: ObservableObject {
    associatedtype UR: UserDefaultsRepository
    associatedtype SM: ShortcutModel
    associatedtype OM: ObjectModel
    associatedtype WM: WindowModel
    associatedtype MBM: MenuBarModel
    associatedtype GVM: GeneralSettingsViewModel
    associatedtype CsVM: CanvasSettingsViewModel

    var settingsTab: SettingsTabType { get set }
    var userDefaultsRepository: UR { get }
    var shortcutModel: SM { get }
}

final class ScreenNoteAppModelImpl: NSObject, ScreenNoteAppModel {
    typealias UR = UserDefaultsRepositoryImpl
    typealias SM = ShortcutModelImpl
    typealias OM = ObjectModelImpl
    typealias WM = WindowModelImpl<WorkspaceViewModelImpl>
    typealias MBM = MenuBarModelImpl<IssueReporterImpl>
    typealias GVM = GeneralSettingsViewModelImpl<LaunchAtLoginRepositoryImpl>
    typealias CsVM = CanvasSettingsViewModelImpl

    @Published var settingsTab: SettingsTabType = .general

    let userDefaultsRepository: UR
    let shortcutModel: SM
    private let objectModel: OM
    private let windowModel: WM
    private let menuBarModel: MBM
    private var menuBar: MenuBar?
    private var cancellables = Set<AnyCancellable>()

    override init() {
        userDefaultsRepository = UR()
        shortcutModel = SM(userDefaultsRepository)
        objectModel = OM(userDefaultsRepository)
        windowModel = WM(userDefaultsRepository, shortcutModel, objectModel)
        menuBarModel = MBM(windowModel)
        super.init()

        NotificationCenter.default
            .publisher(for: NSApplication.didFinishLaunchingNotification)
            .sink { [weak self] _ in
                self?.applicationDidFinishLaunching()
            }
            .store(in: &cancellables)
        NotificationCenter.default
            .publisher(for: NSApplication.willTerminateNotification)
            .sink { [weak self] _ in
                self?.applicationWillTerminate()
            }
            .store(in: &cancellables)
    }

    private func applicationDidFinishLaunching() {
        menuBar = MenuBar(menuBarModel: menuBarModel)
        shortcutModel.setShortcut()
        let toggleMethod = userDefaultsRepository.toggleMethod
        let modifierFlag = userDefaultsRepository.modifierFlag
        windowModel.fadeInShortcutPanel(toggleMethod, modifierFlag)
    }

    private func applicationWillTerminate() {
        windowModel.fadeOutShortcutPanel()
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class ScreenNoteAppModelMock: ScreenNoteAppModel {
        typealias UR = UserDefaultsRepositoryMock
        typealias SM = ShortcutModelMock
        typealias OM = ObjectModelMock
        typealias WM = WindowModelMock
        typealias MBM = MenuBarModelMock
        typealias GVM = GeneralSettingsViewModelMock
        typealias CsVM = CanvasSettingsViewModelMock

        @Published var settingsTab: SettingsTabType = .general
        var userDefaultsRepository = UR()
        var shortcutModel = SM()
    }
}
