import DataSource
import SwiftUI

struct ObjectArrangePopover: View {
    let toolBarDirection: ToolBarDirection
    let arrangeHandler: (ArrangeMethod) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(ArrangeMethod.allCases) { arrangeMethod in
                Button {
                    arrangeHandler(arrangeMethod)
                } label: {
                    Image(systemName: arrangeMethod.symbolName)
                }
                .buttonStyle(.toolBar(toolBarDirection))
                .help(Text(arrangeMethod.help, bundle: .module))
            }
        }
        .padding(8)
    }
}
