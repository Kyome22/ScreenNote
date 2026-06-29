import Model
import SwiftUI

struct DeleteButton: View {
    var store: Workspace

    var body: some View {
        Button {
            Task {
                await store.send(.deleteButtonTapped)
            }
        } label: {
            Image(systemName: "trash.fill")
        }
        .buttonStyle(.toolBar(store.toolBarPosition.direction))
        .disabled(store.disabledEditObject)
        .help(Text("delete", bundle: .module))
    }
}
