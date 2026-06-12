import DataSource
import SwiftUI

extension AlignMethod {
    var symbolName: String {
        switch self {
        case .horizontalAlignLeft:   "align.horizontal.left.fill"
        case .horizontalAlignCenter: "align.horizontal.center.fill"
        case .horizontalAlignRight:  "align.horizontal.right.fill"
        case .verticalAlignTop:      "align.vertical.top.fill"
        case .verticalAlignCenter:   "align.vertical.center.fill"
        case .verticalAlignBottom:   "align.vertical.bottom.fill"
        }
    }

    var help: LocalizedStringKey {
        switch self {
        case .horizontalAlignLeft:   "horizontalAlignLeft"
        case .horizontalAlignCenter: "horizontalAlignCenter"
        case .horizontalAlignRight:  "horizontalAlignRight"
        case .verticalAlignTop:      "verticalAlignTop"
        case .verticalAlignCenter:   "verticalAlignCenter"
        case .verticalAlignBottom:   "verticalAlignBottom"
        }
    }
}
