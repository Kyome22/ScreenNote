import SpiceKey

extension ModifierFlag {
    var label: String {
        String(localized: "\(string)\(title)key", bundle: .module)
    }
}
