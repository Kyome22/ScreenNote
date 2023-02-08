/*
  WorkspaceView.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/01/31.
  
*/

import SwiftUI

struct WorkspaceView<WVM: WorkspaceViewModel, OM: ObjectModel>: View {
    @StateObject private var viewModel: WVM
    @ObservedObject private var objectModel: OM

    init(viewModel: WVM, objectModel: OM) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.objectModel = objectModel
    }

    var body: some View {
        switch viewModel.toolBarPosition {
        case .top:
            VStack(spacing: 0) {
                HorizontalToolBar(objectModel, arrowEdge: .bottom)
                CanvasView(objectModel)
            }
        case .right:
            HStack(spacing: 0) {
                CanvasView(objectModel)
                VerticalToolBar(objectModel, arrowEdge: .leading)
            }
        case .bottom:
            VStack(spacing: 0) {
                CanvasView(objectModel)
                HorizontalToolBar(objectModel, arrowEdge: .top)
            }
        case .left:
            HStack(spacing: 0) {
                VerticalToolBar(objectModel, arrowEdge: .trailing)
                CanvasView(objectModel)
            }
        }
    }
}

struct WorkspaceView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceView(viewModel: PreviewMock.WorkspaceViewModelMock(),
                      objectModel: PreviewMock.ObjectModelMock())
    }
}
