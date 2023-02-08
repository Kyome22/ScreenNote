/*
  ShortcutPanel.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/30.
  
*/

import AppKit
import SpiceKey
import SwiftUI

final class ShortcutPanel: NSPanel {
    init(_ toggleMethod: ToggleMethod, _ modifierFlag: ModifierFlag) {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 20, height: 20),
                   styleMask: [.borderless, .nonactivatingPanel],
                   backing: .buffered,
                   defer: false)
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces]
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        self.alphaValue = 0.0

        let shortcutView = ShortcutView(toggleMethod, modifierFlag)
        let hostingView = NSHostingView(rootView: shortcutView)
        hostingView.setFrameSize(hostingView.fittingSize)
        self.contentView = hostingView
    }

    func fadeIn() {
        self.orderFrontRegardless()
        if let screenFrame = NSScreen.main?.frame {
            let size = self.frame.size
            let origin = NSPoint(x: 0.5 * (screenFrame.width - size.width),
                                 y: 0.5 * (screenFrame.height - size.height))
            self.setFrameOrigin(origin)
        } else {
            self.center()
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
