import DataSource
import SpiceKey
import SwiftUI

struct ShortcutView: View {
    let toggleMethod: ToggleMethod
    let modifierFlag: ModifierFlag

    init(_ toggleMethod: ToggleMethod, _ modifierFlag: ModifierFlag) {
        self.toggleMethod = toggleMethod
        self.modifierFlag = modifierFlag
    }

    var body: some View {
        switch toggleMethod {
        case .longPressKey:
            longPressNote
        case .pressBothSideKeys:
            pressBothSideNote
        }
    }

    private var longPressNote: some View {
        VStack(spacing: 20) {
            Text("longPress\(modifierFlag.title)", bundle: .module)
                .font(.body)
                .foregroundColor(Color.secondary)
            Text(modifierFlag.string)
                .font(.system(size: 100, weight: .bold))
                .foregroundColor(Color.secondary)
        }
        .padding(20)
        .background(Color("PanelBackground", bundle: .module))
        .cornerRadius(12)
        .fixedSize()
    }

    private var pressBothSideNote: some View {
        VStack(spacing: 20) {
            Text("pressBothSide\(modifierFlag.title)", bundle: .module)
                .font(.body)
                .foregroundColor(Color.secondary)
            HStack(spacing: 40) {
                Text(modifierFlag.string)
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(Color.secondary)
                Text(modifierFlag.string)
                    .font(.system(size: 100, weight: .bold))
                    .foregroundColor(Color.secondary)
            }
        }
        .padding(20)
        .background(Color("PanelBackground", bundle: .module))
        .cornerRadius(12)
        .fixedSize()
    }
}
