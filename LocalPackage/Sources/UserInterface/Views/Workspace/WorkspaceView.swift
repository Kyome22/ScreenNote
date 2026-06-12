import Model
import SwiftUI

struct WorkspaceView: View {
    @StateObject var store: Workspace

    var body: some View {
        Group {
            switch store.toolBarPosition {
            case .top:
                VStack(spacing: 0) {
                    HorizontalToolBar(store: store)
                    CanvasView(store: store)
                }
            case .right:
                HStack(spacing: 0) {
                    CanvasView(store: store)
                    VerticalToolBar(store: store)
                }
            case .bottom:
                VStack(spacing: 0) {
                    CanvasView(store: store)
                    HorizontalToolBar(store: store)
                }
            case .left:
                HStack(spacing: 0) {
                    VerticalToolBar(store: store)
                    CanvasView(store: store)
                }
            }
        }
        .task {
            await store.send(.task(String(describing: Self.self)))
        }
        .onDisappear {
            Task { await store.send(.onDisappear) }
        }
    }
}

extension Workspace: ObservableObject {}
