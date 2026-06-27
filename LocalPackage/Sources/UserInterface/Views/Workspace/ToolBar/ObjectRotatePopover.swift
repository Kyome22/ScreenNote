import DataSource
import SwiftUI

struct ObjectRotatePopover: View {
    let toolBarDirection: ToolBarDirection
    let rotateHandler: (RotateMethod) async -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(RotateMethod.allCases) { rotateMethod in
                Button {
                    Task {
                        await rotateHandler(rotateMethod)
                    }
                } label: {
                    Image(systemName: rotateMethod.symbolName)
                }
                .buttonStyle(.toolBar(toolBarDirection))
                .help(rotateMethod.help)
            }
        }
        .padding(8)
    }
}
