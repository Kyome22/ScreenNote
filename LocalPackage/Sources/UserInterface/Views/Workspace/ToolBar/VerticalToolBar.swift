import AppKit
import Model
import SwiftUI

struct VerticalToolBar: View {
    var store: Workspace

    private var buttons: ToolBarButtons {
        ToolBarButtons(store: store, toolBarDirection: .vertical)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            buttons.historyButtons
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    buttons.objectTypeButton(.text)
                        .keyboardShortcut("t", modifiers: [])
                    buttons.objectTypeButton(.pen)
                        .keyboardShortcut("p", modifiers: [])
                }
                HStack(spacing: 8) {
                    buttons.objectTypeButton(.line)
                        .keyboardShortcut("l", modifiers: [])
                    buttons.objectTypeButton(.arrow)
                        .keyboardShortcut("a", modifiers: [])
                }
                HStack(spacing: 8) {
                    buttons.objectTypeButton(.fillRect)
                        .keyboardShortcut("r", modifiers: [])
                    buttons.objectTypeButton(.lineRect)
                        .keyboardShortcut("R", modifiers: [.shift])
                }
                HStack(spacing: 8) {
                    buttons.objectTypeButton(.fillOval)
                        .keyboardShortcut("o", modifiers: [])
                    buttons.objectTypeButton(.lineOval)
                        .keyboardShortcut("O", modifiers: [.shift])
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    buttons.objectTypeButton(.select)
                        .keyboardShortcut("s", modifiers: [])
                    buttons.colorButton
                }
                HStack(spacing: 8) {
                    buttons.lineWidthButton
                    buttons.arrangeButton
                }
                HStack(spacing: 8) {
                    buttons.alignButton
                    buttons.flipButton
                }
                HStack(spacing: 8) {
                    buttons.rotateButton
                    buttons.duplicateButton
                }
                HStack(spacing: 8) {
                    buttons.deleteButton
                    buttons.clearButton
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                buttons.shortcutDummyButtons
            }
            .overlay(Rectangle())
            .opacity(0)
        }
        .padding(.vertical, 8)
        .frame(width: 80)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
    }
}
