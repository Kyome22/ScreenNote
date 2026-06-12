import SpiceKey
import SwiftUI

extension ModifierFlag {
    var label: String {
        String(localized: "\(string)\(title)key", bundle: .module)
    }
}
