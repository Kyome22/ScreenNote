import DataSource
import Foundation

extension TriggerMethod {
    var label: String {
        let localizationValue: String.LocalizationValue = switch self {
        case .longPressKey:
            "longPressModifierKey"
        case .pressBothSideKeys:
            "pressBothSideModifierKeys"
        }
        return String(localized: localizationValue, bundle: .module)
    }
}
