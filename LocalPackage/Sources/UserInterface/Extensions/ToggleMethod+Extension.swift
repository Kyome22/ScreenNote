import DataSource
import SwiftUI

extension ToggleMethod {
    var label: LocalizedStringKey {
        switch self {
        case .longPressKey:      "longPressModifierKey"
        case .pressBothSideKeys: "pressBothSideModifierKeys"
        }
    }
}
