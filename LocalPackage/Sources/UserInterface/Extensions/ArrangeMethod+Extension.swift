import DataSource
import Foundation

extension ArrangeMethod {
    var symbolName: String {
        switch self {
        case .bringToFrontmost: 
            "square.3.stack.3d.top.filled"
        case .sendToBackmost:
            "square.3.stack.3d.bottom.filled"
        }
    }

    var help: String {
        let localizationValue: String.LocalizationValue = switch self {
        case .bringToFrontmost:
            "bringFront"
        case .sendToBackmost:
            "sendBack"
        }
        return String(localized: localizationValue, bundle: .module)
    }
}
