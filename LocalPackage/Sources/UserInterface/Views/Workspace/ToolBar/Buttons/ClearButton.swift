import Model
import SwiftUI

struct ClearButton: View {
    var store: Workspace

    var body: some View {
        Button {
            Task {
                await store.send(.clearButtonTapped)
            }
        } label: {
            Image(systemName: "rays")
        }
        .buttonStyle(.toolBar(store.toolBarPosition.direction))
        .disabled(store.disabledWhileInputtingText)
        .help(Text("clear", bundle: .module))
    }
}
