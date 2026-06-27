import DataSource
import SwiftUI

extension ToolBarPosition {
    var label: String {
        let localizationValue: String.LocalizationValue = switch self {
        case .top:
            "top"
        case .right:
            "right"
        case .bottom:
            "bottom"
        case .left:
            "left"
        }
        return String(localized: localizationValue, bundle: .module)
    }

    var arrowEdge: Edge {
        switch self {
        case .top:
            Edge.bottom
        case .right:
            Edge.leading
        case .bottom:
            Edge.top
        case .left:
            Edge.trailing
        }
    }
}
