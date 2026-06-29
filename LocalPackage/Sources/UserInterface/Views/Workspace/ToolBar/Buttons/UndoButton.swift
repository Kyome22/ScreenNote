import DataSource
import Model
import SwiftUI

struct UndoButton: View {
    var store: Workspace

    var body: some View {
        Button {
            Task {
                await store.send(.undoButtonTapped)
            }
        } label: {
            Image(systemName: "arrowshape.turn.up.backward.fill")
        }
        .buttonStyle(.toolBar(store.toolBarPosition.direction))
        .keyboardShortcut("z", modifiers: .command)
        .help(Text("goBack", bundle: .module))
        .disabled(store.disabledWhileInputtingText)
    }
}
