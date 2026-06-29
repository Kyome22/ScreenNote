import DataSource
import Model
import SwiftUI

struct FlipButton: View {
    @Bindable var store: Workspace

    var body: some View {
        Button {
            Task {
                await store.send(.flipButtonTapped)
            }
        } label: {
            Image(systemName: FlipMethod.flipHorizontal.symbolName)
        }
        .buttonStyle(.toolBar(store.toolBarPosition.direction))
        .disabled(store.disabledEditObject)
        .help(Text("flip", bundle: .module))
        .popover(isPresented: $store.showingFlipPopover, arrowEdge: store.toolBarPosition.arrowEdge) {
            HStack(spacing: 8) {
                ForEach(FlipMethod.allCases) { flipMethod in
                    Button {
                        Task {
                            await store.send(.flipMethodSelected(flipMethod))
                        }
                    } label: {
                        Image(systemName: flipMethod.symbolName)
                    }
                    .buttonStyle(.toolBar(store.toolBarPosition.direction))
                    .help(flipMethod.help)
                }
            }
            .padding(16)
        }
    }
}
