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
    associatedtype LR: LaunchAtLoginRepository
    associatedtype SM: ShortcutModel

    var userDefaultsRepository: UR { get }
    var launchAtLoginRepository: LR { get }
    var shortcutModel: SM { get }
}

final class ScreenNoteAppModelImpl: NSObject, ScreenNoteAppModel {
    typealias UR = UserDefaultsRepositoryImpl
    typealias LR = LaunchAtLoginRepositoryImpl
    typealias SM = ShortcutModelImpl
    typealias WMConcrete = WindowModelImpl<UR, SM<UR>, ObjectModelImpl>
    typealias MMConcrete = MenuBarModelImpl<IssueReporterImpl, WMConcrete>

    let userDefaultsRepository: UR
    let launchAtLoginRepository: LR
    let shortcutModel: SM<UR>
    private let objectModel: ObjectModelImpl
    private let windowModel: WMConcrete
    private let menuBarModel: MMConcrete
    private var menuBar: MenuBar<MMConcrete>?
    private var cancellables = Set<AnyCancellable>()

    override init() {
        userDefaultsRepository = UR()
        launchAtLoginRepository = LR()
        shortcutModel = SM(userDefaultsRepository)
        objectModel = ObjectModelImpl()
        windowModel = WMConcrete(userDefaultsRepository, shortcutModel, objectModel)
        menuBarModel = MMConcrete(windowModel)
        super.init()

        NotificationCenter.default.publisher(for: NSApplication.didFinishLaunchingNotification)
            .sink { [weak self] _ in
                self?.applicationDidFinishLaunching()
            }
            .store(in: &cancellables)
        NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)
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
        typealias LR = LaunchAtLoginRepositoryMock
        typealias SM = ShortcutModelMock

        var userDefaultsRepository = UR()
        var launchAtLoginRepository = LR()
        var shortcutModel = SM()
    }
}
