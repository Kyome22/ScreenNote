import DataSource
import Foundation

extension CanvasVisibility {
    var label: String {
        let localizationValue: String.LocalizationValue = switch self {
        case .visible:
            "hideCanvas"
        case .hidden:
            "showCanvas"
        }
        return String(localized: localizationValue, bundle: .module)
    }
}
