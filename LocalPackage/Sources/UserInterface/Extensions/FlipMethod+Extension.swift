import DataSource
import SwiftUI

extension FlipMethod {
    var symbolName: String {
        switch self {
        case .flipHorizontal:
            "arrow.left.and.right.righttriangle.left.righttriangle.right.fill"
        case .flipVertical:
            "arrow.up.and.down.righttriangle.up.righttriangle.down.fill"
        }
    }

    var help: LocalizedStringKey {
        switch self {
        case .flipHorizontal: "flipHorizontal"
        case .flipVertical:   "flipVertical"
        }
    }
}
