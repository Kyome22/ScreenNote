import Foundation

extension ProcessInfo {
    static var needsResetUserDefaults: Bool {
#if DEBUG
        Self.processInfo.arguments.contains("ResetUserDefaults")
#else
        false
#endif
    }

    static var needsShowAllData: Bool {
#if DEBUG
        Self.processInfo.arguments.contains("ShowAllData")
#else
        false
#endif
    }

    public static var isPreview: Bool {
#if DEBUG
        Self.processInfo.arguments.contains("IsPreview")
#else
        false
#endif
    }
}
