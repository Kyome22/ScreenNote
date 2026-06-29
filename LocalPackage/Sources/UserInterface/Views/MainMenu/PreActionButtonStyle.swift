import SwiftUI

struct PreActionButtonStyle: PrimitiveButtonStyle {
    var preAction: () async -> Void

    init(preAction: @escaping () async -> Void) {
        self.preAction = preAction
    }

    func makeBody(configuration: Configuration) -> some View {
        Button(role: configuration.role) {
            Task {
                await preAction()
                configuration.trigger()
            }
        } label: {
            configuration.label
        }
    }
}

extension PrimitiveButtonStyle where Self == PreActionButtonStyle {
    static func preAction(perform action: @escaping () async -> Void) -> PreActionButtonStyle {
        PreActionButtonStyle(preAction: action)
    }
}
