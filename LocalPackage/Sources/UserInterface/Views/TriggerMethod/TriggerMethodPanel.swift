import DataSource
import Model
import SpiceKey
import SwiftUI

final class TriggerMethodPanel: NSPanel {
    init<Content: View>(
        _ appDependencies: AppDependencies,
        @ViewBuilder content: (TriggerMethod, ModifierFlag) -> Content
    ) {
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
        let userDefaultsRepository = UserDefaultsRepository(appDependencies.userDefaultsClient)
        let triggerMethod = userDefaultsRepository.triggerMethod
        let modifierFlag = userDefaultsRepository.modifierFlag
        contentView = NSHostingView(rootView: content(triggerMethod, modifierFlag))
    }

    override func orderFrontRegardless() {
        super.orderFrontRegardless()
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
