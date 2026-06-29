import DataSource
import Model
import SwiftUI

struct ArrangeButton: View {
    @Bindable var store: Workspace

    var body: some View {
        Button {
            Task {
                await store.send(.arrangeButtonTapped)
            }
        } label: {
            Image(systemName: "square.3.stack.3d.middle.filled")
        }
        .buttonStyle(.toolBar(store.toolBarPosition.direction))
        .disabled(store.disabledEditObject)
        .help(Text("arrange", bundle: .module))
        .popover(isPresented: $store.showingArrangePopover, arrowEdge: store.toolBarPosition.arrowEdge) {
            HStack(spacing: 8) {
                ForEach(ArrangeMethod.allCases) { arrangeMethod in
                    Button {
                        Task {
                            await store.send(.arrangeMethodSelected(arrangeMethod))
                        }
                    } label: {
                        Image(systemName: arrangeMethod.symbolName)
                    }
                    .buttonStyle(.toolBar(store.toolBarPosition.direction))
                    .help(arrangeMethod.help)
                }
            }
            .padding(16)
        }
    }
}
