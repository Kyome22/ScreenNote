import AppKit
import Model
import SwiftUI

struct HorizontalToolBar: View {
    var store: Workspace

    private var buttons: ToolBarButtons {
        ToolBarButtons(store: store, toolBarDirection: .horizontal)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            buttons.historyButtons
            HStack(spacing: 8) {
                buttons.objectTypeButton(.text)
                    .keyboardShortcut("t", modifiers: [])
                buttons.objectTypeButton(.pen)
                    .keyboardShortcut("p", modifiers: [])
                buttons.objectTypeButton(.line)
                    .keyboardShortcut("l", modifiers: [])
                buttons.objectTypeButton(.arrow)
                    .keyboardShortcut("a", modifiers: [])
                buttons.objectTypeButton(.fillRect)
                    .keyboardShortcut("r", modifiers: [])
                buttons.objectTypeButton(.lineRect)
                    .keyboardShortcut("R", modifiers: [.shift])
                buttons.objectTypeButton(.fillOval)
                    .keyboardShortcut("o", modifiers: [])
                buttons.objectTypeButton(.lineOval)
                    .keyboardShortcut("O", modifiers: [.shift])
            }
            HStack(spacing: 8) {
                buttons.objectTypeButton(.select)
                    .keyboardShortcut("s", modifiers: [])
                buttons.colorButton
                buttons.lineWidthButton
                buttons.arrangeButton
                buttons.alignButton
                buttons.flipButton
                buttons.rotateButton
                buttons.duplicateButton
                buttons.deleteButton
                buttons.clearButton
            }
            HStack(spacing: 8) {
                buttons.shortcutDummyButtons
            }
            .overlay(Rectangle())
            .opacity(0)
        }
        .padding(.horizontal, 8)
        .frame(height: 40)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
    }
}
