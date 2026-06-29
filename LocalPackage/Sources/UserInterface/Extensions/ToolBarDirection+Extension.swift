import CoreGraphics
import DataSource

extension ToolBarDirection {
    var buttonWidth: CGFloat {
        switch self {
        case .horizontal:
            40
        case .vertical:
            30
        }
    }
}
