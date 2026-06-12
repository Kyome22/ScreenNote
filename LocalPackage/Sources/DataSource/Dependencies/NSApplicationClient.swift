import AppKit

public struct NSApplicationClient: DependencyClient {
    public var activate: @Sendable () -> Void
    public var terminate: @Sendable () -> Void
    public var orderFrontAboutPanel: @Sendable () -> Void

    public static let liveValue = Self(
        activate: {
            MainActor.assumeIsolated { NSApp.activate(ignoringOtherApps: true) }
        },
        terminate: {
            MainActor.assumeIsolated { NSApp.terminate(nil) }
        },
        orderFrontAboutPanel: {
            MainActor.assumeIsolated {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.orderFrontStandardAboutPanel(nil)
            }
        }
    )

    public static let testValue = Self(
        activate: {},
        terminate: {},
        orderFrontAboutPanel: {}
    )
}
