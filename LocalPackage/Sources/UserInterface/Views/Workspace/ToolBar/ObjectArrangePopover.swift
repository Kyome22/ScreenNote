import DataSource
import SwiftUI

struct ObjectArrangePopover: View {
    let toolBarDirection: ToolBarDirection
    let arrangeHandler: (ArrangeMethod) async -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(ArrangeMethod.allCases) { arrangeMethod in
                Button {
                    Task {
                        await arrangeHandler(arrangeMethod)
                    }
                } label: {
                    Image(systemName: arrangeMethod.symbolName)
                }
                .buttonStyle(.toolBar(toolBarDirection))
                .help(arrangeMethod.help)
            }
        }
        .padding(8)
    }
}
