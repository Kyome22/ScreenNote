import DataSource
import SwiftUI

struct ObjectAlignPopover: View {
    let toolBarDirection: ToolBarDirection
    let alignHandler: (AlignMethod) async -> Void

    var body: some View {
        VStack {
            HStack(spacing: 8) {
                ForEach(AlignMethod.horizontals) { alignMethod in
                    alignButton(alignMethod)
                }
            }
            HStack(spacing: 8) {
                ForEach(AlignMethod.verticals) { alignMethod in
                    alignButton(alignMethod)
                }
            }
        }
        .padding(8)
    }

    private func alignButton(_ alignMethod: AlignMethod) -> some View {
        Button {
            Task {
                await alignHandler(alignMethod)
            }
        } label: {
            Image(systemName: alignMethod.symbolName)
        }
        .buttonStyle(.toolBar(toolBarDirection))
        .help(alignMethod.help)
    }
}
