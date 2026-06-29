import DataSource
import Model
import SwiftUI

struct RotateButton: View {
    @Bindable var store: Workspace

    var body: some View {
        Button {
            Task {
                await store.send(.rotateButtonTapped)
            }
        } label: {
            Image(systemName: RotateMethod.rotateRight.symbolName)
        }
        .buttonStyle(.toolBar(store.toolBarPosition.direction))
        .disabled(store.disabledEditObject)
        .help(Text("rotate", bundle: .module))
        .popover(isPresented: $store.showingRotatePopover, arrowEdge: store.toolBarPosition.arrowEdge) {
            HStack(spacing: 8) {
                ForEach(RotateMethod.allCases) { rotateMethod in
                    Button {
                        Task {
                            await store.send(.rotateMethodSelected(rotateMethod))
                        }
                    } label: {
                        Image(systemName: rotateMethod.symbolName)
                    }
                    .buttonStyle(.toolBar(store.toolBarPosition.direction))
                    .help(rotateMethod.help)
                }
            }
            .padding(16)
        }
    }
}
