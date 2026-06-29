import DataSource
import SwiftUI

struct ToolBarRadioButtonStyle: ButtonStyle {
    var toolBarDirection: ToolBarDirection
    var backgroundColor: Color

    init(toolBarDirection: ToolBarDirection, selection: Bool) {
        self.toolBarDirection = toolBarDirection
        self.backgroundColor = selection ? Color.accentColor : Color.gray
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, design: .monospaced))
            .frame(width: toolBarDirection.buttonWidth, height: 30, alignment: .center)
            .background(backgroundColor.opacity(configuration.isPressed ? 0.8 : 0.6), in: .rect(cornerRadius: 6))
    }
}

extension ButtonStyle where Self == ToolBarRadioButtonStyle {
    static func toolBarRadio(
        _ toolBarDirection: ToolBarDirection,
        _ selection: Bool
    ) -> ToolBarRadioButtonStyle {
        ToolBarRadioButtonStyle(toolBarDirection: toolBarDirection, selection: selection)
    }
}
