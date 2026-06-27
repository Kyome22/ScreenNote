import DataSource
import Model
import SwiftUI

final class WorkspacePanel: NSPanel {
    override var canBecomeKey: Bool { true }

    init<Content: View>(_ appDependencies: AppDependencies, @ViewBuilder content: () -> Content) {
        super.init(
            contentRect: CGRect(x: 0, y: 0, width: 20, height: 20),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        level = .popUpMenu
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isOpaque = false
        hasShadow = false
        let userDefaultsRepository = UserDefaultsRepository(appDependencies.userDefaultsClient)
        backgroundColor = NSColor(
            white: 1.0 - CGFloat(userDefaultsRepository.backgroundColorIndex),
            alpha: max(0.01, userDefaultsRepository.backgroundOpacity)
        )
        alphaValue = 0.0
        contentView = WorkspaceHostingView(rootView: content())
    }

    override func orderFrontRegardless() {
        super.orderFrontRegardless()
        if let visibleFrame = NSScreen.main?.visibleFrame {
            setFrame(visibleFrame, display: true, animate: false)
        }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            animator().alphaValue = 1.0
        }
    }

    override func close() {
        resignKey()
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            animator().alphaValue = 0.0
        } completionHandler: {
            MainActor.assumeIsolated {
                super.close()
            }
        }
    }
}

final class WorkspaceHostingView<T: View>: NSHostingView<T> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}
