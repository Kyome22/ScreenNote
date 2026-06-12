import DataSource
import SwiftUI

extension CanvasVisible {
    var label: LocalizedStringKey {
        switch self {
        case .show: "hideCanvas"
        case .hide: "showCanvas"
        }
    }
}
