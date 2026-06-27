import DataSource
import SpiceKey
import SwiftUI

struct TriggerMethodView: View {
    var triggerMethod: TriggerMethod
    var modifierFlag: ModifierFlag

    var body: some View {
        Group {
            switch triggerMethod {
            case .longPressKey:
                VStack(spacing: 20) {
                    Text("longPress\(modifierFlag.title)", bundle: .module)
                        .foregroundStyle(Color.secondary)
                    Text(modifierFlag.string)
                        .font(.system(size: 100, weight: .bold))
                        .foregroundStyle(Color.secondary)
                }

            case .pressBothSideKeys:
                VStack(spacing: 20) {
                    Text("pressBothSide\(modifierFlag.title)", bundle: .module)
                        .foregroundStyle(Color.secondary)
                    HStack(spacing: 40) {
                        Text(modifierFlag.string)
                        Text(modifierFlag.string)
                    }
                    .font(.system(size: 100, weight: .bold))
                    .foregroundStyle(Color.secondary)
                }
            }
        }
        .padding(20)
        .background(Color(.panelBackground))
        .cornerRadius(12)
        .fixedSize()
    }
}
