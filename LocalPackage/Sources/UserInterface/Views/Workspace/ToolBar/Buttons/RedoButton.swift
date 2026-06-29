import DataSource
import Model
import SwiftUI

struct RedoButton: View {
    var store: Workspace

    var body: some View {
        Button {
            Task {
                await store.send(.redoButtonTapped)
            }
        } label: {
            Image(systemName: "arrowshape.turn.up.forward.fill")
        }
        .buttonStyle(.toolBar(store.toolBarPosition.direction))
        .keyboardShortcut("z", modifiers: [.shift, .command])
        .help(Text("goForward", bundle: .module))
        .disabled(store.disabledWhileInputtingText)
    }
}
