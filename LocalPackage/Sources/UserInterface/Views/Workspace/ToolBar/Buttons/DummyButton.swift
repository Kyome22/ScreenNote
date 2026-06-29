import SwiftUI

struct DummyButton: View {
    var key: KeyEquivalent
    var modifiers: EventModifiers
    var action: () async -> Void

    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            EmptyView()
        }
        .keyboardShortcut(key, modifiers: modifiers)
    }
}
