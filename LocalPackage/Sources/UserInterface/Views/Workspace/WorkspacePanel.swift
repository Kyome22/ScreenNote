import AppKit
import DataSource
import Model
import SwiftUI

final class WorkspaceHostingView<T: View>: NSHostingView<T> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

final class WorkspacePanel: NSPanel {
    override var canBecomeKey: Bool { true }

    init(_ appDependencies: AppDependencies) {
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
        let userDefaultsRepository = UserDefaultsRepository(
            appDependencies.userDefaultsClient,
            appDependencies.appStateClient
        )
        let white = 1.0 - CGFloat(userDefaultsRepository.backgroundColorIndex)
        let alpha = max(0.01, userDefaultsRepository.backgroundOpacity)
        backgroundColor = NSColor(white: white, alpha: alpha)
        alphaValue = 0.0
        let workspaceView = WorkspaceView(store: Workspace(appDependencies))
        contentView = WorkspaceHostingView(rootView: workspaceView)
    }

    func fadeIn() {
        orderFrontRegardless()
        if let visibleFrame = NSScreen.main?.visibleFrame {
            setFrame(visibleFrame, display: true, animate: false)
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
