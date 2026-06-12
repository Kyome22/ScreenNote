import DataSource
import SwiftUI

struct ObjectFlipPopover: View {
    let toolBarDirection: ToolBarDirection
    let flipHandler: (FlipMethod) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(FlipMethod.allCases) { flipMethod in
                Button {
                    flipHandler(flipMethod)
                } label: {
                    Image(systemName: flipMethod.symbolName)
                }
                .buttonStyle(.toolBar(toolBarDirection))
                .help(Text(flipMethod.help, bundle: .module))
            }
        }
        .padding(8)
    }
}
