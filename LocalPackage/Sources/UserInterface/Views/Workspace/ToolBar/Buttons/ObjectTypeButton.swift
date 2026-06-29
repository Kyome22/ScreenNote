import DataSource
import Model
import SwiftUI

struct ObjectTypeButton: View {
    var store: Workspace
    var objectType: ObjectType

    var body: some View {
        Button {
            Task {
                await store.send(.objectTypeSelected(objectType))
            }
        } label: {
            Image(systemName: objectType.symbolName)
        }
        .buttonStyle(.toolBarRadio(
            store.toolBarPosition.direction,
            store.canvasState.objectType == objectType
        ))
        .keyboardShortcut(objectType.key, modifiers: objectType.modifiers)
        .help(objectType.help)
    }
}
