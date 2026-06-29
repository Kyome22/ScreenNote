import DataSource
import Model
import SwiftUI

struct AlignButton: View {
    @Bindable var store: Workspace

    var body: some View {
        Button {
            Task {
                await store.send(.alignButtonTapped)
            }
        } label: {
            Image(systemName: AlignMethod.horizontalAlignLeft.symbolName)
        }
        .buttonStyle(.toolBar(store.toolBarPosition.direction))
        .disabled(store.disabledEditObject)
        .help(Text("align", bundle: .module))
        .popover(isPresented: $store.showingAlignPopover, arrowEdge: store.toolBarPosition.arrowEdge) {
            VStack {
                HStack(spacing: 8) {
                    ForEach(AlignMethod.horizontals) { alignMethod in
                        rowButton(alignMethod)
                    }
                }
                HStack(spacing: 8) {
                    ForEach(AlignMethod.verticals) { alignMethod in
                        rowButton(alignMethod)
                    }
                }
            }
            .padding(16)
        }
    }

    private func rowButton(_ alignMethod: AlignMethod) -> some View {
        Button {
            Task {
                await store.send(.alignMethodSelected(alignMethod))
            }
        } label: {
            Image(systemName: alignMethod.symbolName)
        }
        .buttonStyle(.toolBar(store.toolBarPosition.direction))
        .help(alignMethod.help)
    }
}
