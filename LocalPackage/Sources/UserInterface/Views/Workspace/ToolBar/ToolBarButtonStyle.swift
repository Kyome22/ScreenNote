import DataSource
import SwiftUI

struct ToolBarButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    var toolBarDirection: ToolBarDirection

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, design: .monospaced))
            .frame(width: toolBarDirection.buttonWidth, height: 30, alignment: .center)
            .background(Color.gray.opacity(configuration.isPressed ? 0.8 : 0.6), in: .rect(cornerRadius: 6))
            .opacity(isEnabled ? 1.0 : 0.5)
    }
}

extension ButtonStyle where Self == ToolBarButtonStyle {
    static func toolBar(_ toolBarDirection: ToolBarDirection) -> ToolBarButtonStyle {
        ToolBarButtonStyle(toolBarDirection: toolBarDirection)
    }
}
