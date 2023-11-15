/*
 WorkspaceView.swift
 ScreenNote

 Created by Takuto Nakamura on 2023/01/31.
 Copyright © 2023 Studio Kyome. All rights reserved.
*/

import SwiftUI

struct WorkspaceView<WVM: WorkspaceViewModel>: View {
    @StateObject var viewModel: WVM

    var body: some View {
        switch viewModel.toolBarPosition {
        case .top:
            VStack(spacing: 0) {
                HorizontalToolBar(toolBarModel: WVM.TBM(objectModel: viewModel.objectModel,
                                                        arrowEdge: .bottom))
                CanvasView(viewMode: WVM.CVM(objectModel: viewModel.objectModel))
            }
        case .right:
            HStack(spacing: 0) {
                CanvasView(viewMode: WVM.CVM(objectModel: viewModel.objectModel))
                VerticalToolBar(toolBarModel: WVM.TBM(objectModel: viewModel.objectModel,
                                                      arrowEdge: .leading))
            }
        case .bottom:
            VStack(spacing: 0) {
                CanvasView(viewMode: WVM.CVM(objectModel: viewModel.objectModel))
                HorizontalToolBar(toolBarModel: WVM.TBM(objectModel: viewModel.objectModel,
                                                        arrowEdge: .top))
            }
        case .left:
            HStack(spacing: 0) {
                VerticalToolBar(toolBarModel: WVM.TBM(objectModel: viewModel.objectModel,
                                                      arrowEdge: .trailing))
                CanvasView(viewMode: WVM.CVM(objectModel: viewModel.objectModel))
            }
        }
    }
}

#Preview {
    WorkspaceView(viewModel: PreviewMock.WorkspaceViewModelMock())
}
