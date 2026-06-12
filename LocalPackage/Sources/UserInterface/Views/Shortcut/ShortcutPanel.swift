import AppKit
import DataSource
import SpiceKey
import SwiftUI

final class ShortcutPanel: NSPanel {
    init(_ toggleMethod: ToggleMethod, _ modifierFlag: ModifierFlag) {
        super.init(
            contentRect: CGRect(x: 0, y: 0, width: 20, height: 20),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        level = .floating
        collectionBehavior = [.canJoinAllSpaces]
        isOpaque = false
        backgroundColor = .clear
        alphaValue = 0.0
        let hostingView = NSHostingView(rootView: ShortcutView(toggleMethod, modifierFlag))
        hostingView.setFrameSize(hostingView.fittingSize)
        contentView = hostingView
    }

    func fadeIn() {
        orderFrontRegardless()
        if let screenFrame = NSScreen.main?.frame {
            let size = frame.size
            let origin = CGPoint(
                x: 0.5 * (screenFrame.width - size.width),
                y: 0.5 * (screenFrame.height - size.height)
            )
            setFrameOrigin(origin)
        } else {
            center()
        }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            animator().alphaValue = 1.0
        }
    }

    func fadeOut() {
        resignKey()
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            animator().alphaValue = 0.0
        } completionHandler: { [weak self] in
            MainActor.assumeIsolated { self?.close() }
        }
    }
}
