import DataSource
import SwiftUI

struct ObjectRotatePopover: View {
    let toolBarDirection: ToolBarDirection
    let rotateHandler: (RotateMethod) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(RotateMethod.allCases) { rotateMethod in
                Button {
                    rotateHandler(rotateMethod)
                } label: {
                    Image(systemName: rotateMethod.symbolName)
                }
                .buttonStyle(.toolBar(toolBarDirection))
                .help(Text(rotateMethod.help, bundle: .module))
            }
        }
        .padding(8)
    }
}
