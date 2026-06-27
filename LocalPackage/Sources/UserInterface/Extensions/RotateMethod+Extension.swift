import DataSource
import Foundation

extension RotateMethod {
    var symbolName: String {
        switch self {
        case .rotateRight:
            "rotate.right.fill"
        case .rotateLeft:
            "rotate.left.fill"
        }
    }

    var help: String {
        let localizationValue: String.LocalizationValue = switch self {
        case .rotateRight:
            "rotateRight"
        case .rotateLeft:
            "rotateLeft"
        }
        return String(localized: localizationValue, bundle: .module)
    }
}
