/*
  MenuBarModel.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import AppKit
import Combine

protocol MenuBarModel: AnyObject {
    var showOrHideCanvasPublisher: AnyPublisher<Bool, Never> { get }

    init(_ windowModel: WindowModel)

    func toggleCanvasVisible(_ flag: Bool)
    func openSettings()
    func openAbout()
    func sendIssueReport()
    func terminateApp()
}

final class MenuBarModelImpl<IR: IssueReportModel>: MenuBarModel {
    var showOrHideCanvasPublisher: AnyPublisher<Bool, Never>

    private let windowModel: WindowModel

    init(_ windowModel: WindowModel) {
        self.windowModel = windowModel
        self.showOrHideCanvasPublisher = windowModel.showOrHideCanvasPublisher
    }

    func toggleCanvasVisible(_ flag: Bool) {
        if flag {
            windowModel.showCanvas()
        } else {
            windowModel.hideCanvas()
        }
    }

    func openSettings() {
        windowModel.openSettings()
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

        init(_ windowModel: WindowModel) {}

        func toggleCanvasVisible(_ flag: Bool) {}
        func openSettings() {}
        func openAbout() {}
        func sendIssueReport() {}
        func terminateApp() {}
    }
}
