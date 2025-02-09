/*
  CanvasPanel.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/31.
  
*/

import AppKit
import SpiceKey
import SwiftUI

final class WorkspaceHostingView<T: View>: NSHostingView<T> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

final class WorkspacePanel<WVM: WorkspaceViewModel>: NSPanel {
    override var canBecomeKey: Bool { true }

    init(
        _ userDefaultsRepository: UserDefaultsRepository,
        _ objectModel: ObjectModel
    ) {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 20, height: 20),
                   styleMask: [.borderless, .nonactivatingPanel],
                   backing: .buffered,
                   defer: false)
        self.level = .popUpMenu
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isOpaque = false
        self.hasShadow = false
        let white = 1.0 - CGFloat(userDefaultsRepository.backgroundColorIndex)
        let alpha = max(0.01, userDefaultsRepository.backgroundOpacity)
        self.backgroundColor = NSColor(white: white, alpha: alpha)
        self.alphaValue = 0.0
        if userDefaultsRepository.clearAllObjects {
            objectModel.resetHistory()
        }
        objectModel.resetDefaultSettings()
        let viewModel = WVM(objectModel, userDefaultsRepository.toolBarPosition)
        let workspaceView = WorkspaceView(viewModel: viewModel)
        self.contentView = WorkspaceHostingView(rootView: workspaceView)
    }

    func fadeIn() {
        self.orderFrontRegardless()
        if let visibleFrame = NSScreen.main?.visibleFrame {
            self.setFrame(visibleFrame, display: true, animate: false)
        }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            self.animator().alphaValue = 1.0
        }
    }

    func fadeOut() {
        self.resignKey()
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            self.animator().alphaValue = 0
        } completionHandler: {
            self.close()
        }
    }
}
