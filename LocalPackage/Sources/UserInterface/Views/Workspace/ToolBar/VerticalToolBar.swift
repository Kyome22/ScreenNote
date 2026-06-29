import Model
import SwiftUI

struct VerticalToolBar: View {
    var store: Workspace

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                UndoButton(store: store)
                RedoButton(store: store)
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    ObjectTypeButton(store: store, objectType: .text)
                    ObjectTypeButton(store: store, objectType: .pen)
                }
                HStack(spacing: 8) {
                    ObjectTypeButton(store: store, objectType: .line)
                    ObjectTypeButton(store: store, objectType: .arrow)
                }
                HStack(spacing: 8) {
                    ObjectTypeButton(store: store, objectType: .fillRect)
                    ObjectTypeButton(store: store, objectType: .lineRect)
                }
                HStack(spacing: 8) {
                    ObjectTypeButton(store: store, objectType: .fillOval)
                    ObjectTypeButton(store: store, objectType: .lineOval)
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    ObjectTypeButton(store: store, objectType: .select)
                    ColorButton(store: store)
                }
                HStack(spacing: 8) {
                    LineWidthButton(store: store)
                    ArrangeButton(store: store)
                }
                HStack(spacing: 8) {
                    AlignButton(store: store)
                    FlipButton(store: store)
                }
                HStack(spacing: 8) {
                    RotateButton(store: store)
                    DuplicateButton(store: store)
                }
                HStack(spacing: 8) {
                    DeleteButton(store: store)
                    ClearButton(store: store)
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                DummyButton(key: "a", modifiers: .command) {
                    await store.send(.selectAllButtonTapped)
                }
                DummyButton(key: .delete, modifiers: []) {
                    await store.send(.deleteButtonTapped)
                }
                DummyButton(key: .delete, modifiers: .command) {
                    await store.send(.clearButtonTapped)
                }
            }
            .overlay(Rectangle())
            .opacity(0)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.8), in: .rect(cornerRadius: 8))
    }
}
