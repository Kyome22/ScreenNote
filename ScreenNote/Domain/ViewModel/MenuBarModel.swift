/*
  MenuBarModel.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import AppKit
import Combine
import SpiceKey

protocol MenuBarModel: AnyObject {
    var showOrHideCanvasPublisher: AnyPublisher<Bool, Never> { get }

    func toggleCanvasVisible(_ flag: Bool)
    func openPreferences()
    func openAbout()
    func sendIssueReport()
    func terminateApp()
}

final class MenuBarModelImpl<IR: IssueReportModel,
                             WM: WindowModel>: NSObject, MenuBarModel {
    var showOrHideCanvasPublisher: AnyPublisher<Bool, Never>

    private let windowModel: WM
    private var cancellables = Set<AnyCancellable>()

    init(_ windowModel: WM) {
        self.windowModel = windowModel
        self.showOrHideCanvasPublisher = windowModel.showOrHideCanvasPublisher
        super.init()
    }

    func toggleCanvasVisible(_ flag: Bool) {
        if flag {
            windowModel.showCanvas()
        } else {
            windowModel.hideCanvas()
        }
    }

    func openPreferences() {
        windowModel.openPreferences()
    }

    func openAbout() {
        windowModel.openAbout()
    }

    func sendIssueReport() {
        IR.send()
    }

    func terminateApp() {
        NSApp.terminate(nil)
    }
}

// MARK: - Preview Mock
extension PreviewMock {
    final class MenuBarModelMock: MenuBarModel {
        var showOrHideCanvasPublisher: AnyPublisher<Bool, Never> {
            Just(true).eraseToAnyPublisher()
        }

        func toggleCanvasVisible(_ flag: Bool) {}
        func openPreferences() {}
        func openAbout() {}
        func sendIssueReport() {}
        func terminateApp() {}
    }
}
