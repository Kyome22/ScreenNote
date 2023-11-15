/*
 WindowModel.swift
 ScreenNote

 Created by Takuto Nakamura on 2023/01/30.

 */

import AppKit
import Combine
import SpiceKey

protocol WindowModel: AnyObject {
    var showOrHideCanvasPublisher: AnyPublisher<Bool, Never> { get }

    init(_ userDefaultsRepository: UserDefaultsRepository,
         _ shortcutModel: ShortcutModel,
         _ objectModel: ObjectModel)

    func openSettings()
    func openAbout()
    func fadeInShortcutPanel(_ toggleMethod: ToggleMethod, _ modifierFlag: ModifierFlag)
    func fadeOutShortcutPanel()
    func showCanvas()
    func hideCanvas()
}

final class WindowModelImpl<WVM: WorkspaceViewModel>: NSObject, WindowModel, NSWindowDelegate {
    private let showOrHideCanvasSubject = PassthroughSubject<Bool, Never>()
    var showOrHideCanvasPublisher: AnyPublisher<Bool, Never> {
        return showOrHideCanvasSubject.eraseToAnyPublisher()
    }

    private let userDefaultsRepository: UserDefaultsRepository
    private let shortcutModel: ShortcutModel
    private let objectModel: ObjectModel
    private var shortcutPanel: ShortcutPanel?
    private var workspacePanel: WorkspacePanel<WVM>?
    private var cancellables = Set<AnyCancellable>()

    private var settingsWindow: NSWindow? {
        return NSApp.windows.first(where: { window in
            window.frameAutosaveName == "com_apple_SwiftUI_Settings_window"
        })
    }

    init(
        _ userDefaultsRepository: UserDefaultsRepository,
        _ shortcutModel: ShortcutModel,
        _ objectModel: ObjectModel
    ) {
        self.userDefaultsRepository = userDefaultsRepository
        self.shortcutModel = shortcutModel
        self.objectModel = objectModel
        super.init()
        self.shortcutModel.showOrHideCanvasPublisher
            .sink { [weak self] in
                self?.showOrHideCanvas()
            }
            .store(in: &cancellables)
    }

    func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        guard let window = settingsWindow else { return }
        if window.canBecomeMain {
            window.center()
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func openAbout() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(nil)
    }

    func fadeInShortcutPanel(_ toggleMethod: ToggleMethod, _ modifierFlag: ModifierFlag) {
        guard shortcutPanel == nil else { return }
        shortcutPanel = ShortcutPanel(toggleMethod, modifierFlag)
        shortcutPanel?.delegate = self
        shortcutPanel?.fadeIn()
    }

    func fadeOutShortcutPanel() {
        shortcutPanel?.fadeOut()
    }

    private func showOrHideCanvas() {
        if let workspacePanel {
            workspacePanel.fadeOut()
            showOrHideCanvasSubject.send(false)
        } else {
            fadeOutShortcutPanel()
            workspacePanel = WorkspacePanel(userDefaultsRepository, objectModel)
            workspacePanel?.delegate = self
            workspacePanel?.fadeIn()
            showOrHideCanvasSubject.send(true)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func showCanvas() {
        guard workspacePanel == nil else { return }
        workspacePanel = WorkspacePanel(userDefaultsRepository, objectModel)
        workspacePanel?.delegate = self
        workspacePanel?.fadeIn()
        NSApp.activate(ignoringOtherApps: true)
    }

    func hideCanvas() {
        workspacePanel?.fadeOut()
    }

    // MARK: NSWindowDelegate
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        if window === shortcutPanel {
            shortcutPanel = nil
        } else if window === workspacePanel {
            workspacePanel = nil
        }
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class WindowModelMock: WindowModel {
        var showOrHideCanvasPublisher: AnyPublisher<Bool, Never> {
            Just(true).eraseToAnyPublisher()
        }

        init(_ userDefaultsRepository: UserDefaultsRepository,
             _ shortcutModel: ShortcutModel,
             _ objectModel: ObjectModel) {}
        init() {}

        func openSettings() {}
        func openAbout() {}
        func fadeInShortcutPanel(_ toggleMethod: ToggleMethod, _ modifierFlag: ModifierFlag) {}
        func fadeOutShortcutPanel() {}
        func showCanvas() {}
        func hideCanvas() {}
    }
}
