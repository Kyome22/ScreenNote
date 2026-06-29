import Model
import SwiftUI

struct HorizontalToolBar: View {
    var store: Workspace

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            HStack(spacing: 8) {
                UndoButton(store: store)
                RedoButton(store: store)
            }
            HStack(spacing: 8) {
                ObjectTypeButton(store: store, objectType: .text)
                ObjectTypeButton(store: store, objectType: .pen)
                ObjectTypeButton(store: store, objectType: .line)
                ObjectTypeButton(store: store, objectType: .arrow)
                ObjectTypeButton(store: store, objectType: .fillRect)
                ObjectTypeButton(store: store, objectType: .lineRect)
                ObjectTypeButton(store: store, objectType: .fillOval)
                ObjectTypeButton(store: store, objectType: .lineOval)
            }
            HStack(spacing: 8) {
                ObjectTypeButton(store: store, objectType: .select)
                ColorButton(store: store)
                LineWidthButton(store: store)
                ArrangeButton(store: store)
                AlignButton(store: store)
                FlipButton(store: store)
                RotateButton(store: store)
                DuplicateButton(store: store)
                DeleteButton(store: store)
                ClearButton(store: store)
            }
            HStack(spacing: 8) {
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.8), in: .rect(cornerRadius: 8))
    }
}
