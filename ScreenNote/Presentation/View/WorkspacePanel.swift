/*
  CanvasPanel.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/31.
  
*/

import AppKit
import SpiceKey
import SwiftUI

final class WorkspaceHostingView<T: View>: NSHostingView<T> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
}

final class WorkspacePanel<UR: UserDefaultsRepository, OM: ObjectModel>: NSPanel {
    override var canBecomeKey: Bool {
        return true
    }

    init(_ userDefaultsRepository: UR, _ objectModel: OM) {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 20, height: 20),
                   styleMask: [.borderless, .nonactivatingPanel],
                   backing: .buffered,
                   defer: false)
        self.level = .popUpMenu
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isOpaque = false
        self.hasShadow = false
        self.backgroundColor = NSColor(white: 0.0, alpha: 0.01)
        self.alphaValue = 0.0

        if userDefaultsRepository.clearAllObjects {
            objectModel.resetHistory()
        }
        let viewModel = WorkspaceViewModelImpl<UR>(userDefaultsRepository)
        let workspaceView = WorkspaceView(viewModel: viewModel, objectModel: objectModel)
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
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            self.animator().alphaValue = 0
        } completionHandler: {
            self.close()
        }
    }
}
