import Model
import SwiftUI

struct DuplicateButton: View {
    var store: Workspace

    var body: some View {
        Button {
            Task {
                await store.send(.duplicateButtonTapped)
            }
        } label: {
            Image(systemName: "plus.rectangle.fill.on.rectangle.fill")
        }
        .buttonStyle(.toolBar(store.toolBarPosition.direction))
        .disabled(store.disabledEditObject)
        .help(Text("duplicate", bundle: .module))
    }
}
