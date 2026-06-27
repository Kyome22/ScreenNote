import DataSource
import SwiftUI

struct ObjectFlipPopover: View {
    let toolBarDirection: ToolBarDirection
    let flipHandler: (FlipMethod) async -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(FlipMethod.allCases) { flipMethod in
                Button {
                    Task {
                        await flipHandler(flipMethod)
                    }
                } label: {
                    Image(systemName: flipMethod.symbolName)
                }
                .buttonStyle(.toolBar(toolBarDirection))
                .help(flipMethod.help)
            }
        }
        .padding(8)
    }
}
