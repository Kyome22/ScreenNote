import AppKit

extension String {
    static let backgroundColorIndex = "backgroundColorIndex"
    static let backgroundOpacity = "backgroundOpacity"
    static let clearAllObjects = "clearAllObjects"
    static let defaultColorIndex = "defaultColorIndex"
    static let defaultLineWidth = "defaultLineWidth"
    static let defaultObjectType = "defaultObjectType"
    static let defaultOpacity = "defaultOpacity"
    static let longPressSeconds = "longPressSeconds"
    static let modifierFlag = "modifierFlag"
    static let showToggleMethod = "showToggleMethod"
    static let toggleMethod = "toggleMethod"
    static let toolBarPosition = "toolBarPosition"

    public func calculateSize(using font: NSFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        return NSAttributedString(string: self, attributes: attributes).size()
    }
}
