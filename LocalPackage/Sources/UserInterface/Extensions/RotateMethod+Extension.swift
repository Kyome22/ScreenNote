import DataSource
import SwiftUI

extension RotateMethod {
    var symbolName: String {
        switch self {
        case .rotateRight: "rotate.right.fill"
        case .rotateLeft:  "rotate.left.fill"
        }
    }

    var help: LocalizedStringKey {
        switch self {
        case .rotateRight: "rotateRight"
        case .rotateLeft:  "rotateLeft"
        }
    }
}
