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

    func openPreferences()
    func openAbout()
    func fadeInShortcutPanel(_ toggleMethod: ToggleMethod, _ modifierFlag: ModifierFlag)
    func fadeOutShortcutPanel()
    func showCanvas()
    func hideCanvas()
}

final class WindowModelImpl<UR: UserDefaultsRepository,
                            SM: ShortcutModel,
                            OM: ObjectModel>: NSObject, WindowModel, NSWindowDelegate {
    private let showOrHideCanvasSubject = PassthroughSubject<Bool, Never>()
    var showOrHideCanvasPublisher: AnyPublisher<Bool, Never> {
        return showOrHideCanvasSubject.eraseToAnyPublisher()
    }

    private let userDefaultsRepository: UR
    private let shortcutModel: SM
    private let objectModel: OM
    private var shortcutPanel: ShortcutPanel?
    private var workspacePanel: WorkspacePanel<UR, OM>?
    private var cancellables = Set<AnyCancellable>()

    private var settingsWindow: NSWindow? {
        return NSApp.windows.first(where: { window in
            window.frameAutosaveName == "com_apple_SwiftUI_Settings_window"
        })
    }

    init(_ userDefaultsRepository: UR, _ shortcutModel: SM, _ objectModel: OM) {
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

    func openPreferences() {
        if #available(macOS 13, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
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

        func openPreferences() {}
        func openAbout() {}
        func fadeInShortcutPanel(_ toggleMethod: ToggleMethod, _ modifierFlag: ModifierFlag) {}
        func fadeOutShortcutPanel() {}
        func showCanvas() {}
        func hideCanvas() {}
    }
}
