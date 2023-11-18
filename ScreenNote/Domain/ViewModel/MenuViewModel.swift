/*
 MenuViewModel.swift
 ScreenNote

 Created by Takuto Nakamura on 2023/11/18.
 Copyright © 2023 Studio Kyome. All rights reserved.
*/

import AppKit
import SwiftUI
import Combine

protocol MenuViewModel: ObservableObject {
    var canvasVisible: CanvasVisible { get set }

    init(_ windowModel: WindowModel)

    func showOrHide()
    func openSettings()
    func openAbout()
    func sendIssueReport()
    func terminateApp()
}

final class MenuViewModelImpl<IR: IssueReportModel>: MenuViewModel {
    private let windowModel: WindowModel
    private var cancellables = Set<AnyCancellable>()

    @Published var canvasVisible: CanvasVisible = .hide

    init(_ windowModel: WindowModel) {
        self.windowModel = windowModel
        windowModel.canvasVisiblePublisher
            .sink { [weak self] canvasVisible in
                self?.canvasVisible = canvasVisible
            }
            .store(in: &cancellables)
    }

    func showOrHide() {
        if canvasVisible == .hide {
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
    final class MenuViewModelMock: MenuViewModel {
        @Published var canvasVisible: CanvasVisible = .hide

        init(_ windowModel: WindowModel) {}
        init() {}

        func showOrHide() {}
        func openSettings() {}
        func openAbout() {}
        func sendIssueReport() {}
        func terminateApp() {}
    }
}
