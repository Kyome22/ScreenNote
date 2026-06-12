import DataSource
import SwiftUI

extension ToolBarPosition {
    var label: LocalizedStringKey {
        switch self {
        case .top:    "top"
        case .right:  "right"
        case .bottom: "bottom"
        case .left:   "left"
        }
    }

    var arrowEdge: Edge {
        switch self {
        case .top:    .bottom
        case .right:  .leading
        case .bottom: .top
        case .left:   .trailing
        }
    }
}
