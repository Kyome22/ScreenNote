/*
  CanvasSettingsView.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/08.
  
*/

import SwiftUI

struct CanvasSettingsView<CVM: CanvasSettingsViewModel>: View {
    @StateObject private var viewModel: CVM

    init(viewModel: CVM) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                wrapText(maxKey: "wrapTextCanvasTab", key: "objects:")
                Toggle(isOn: $viewModel.clearAllObjects) {
                    Text("clearAllObjects")
                }
            }
            .frame(height: 20)
            HStack(alignment: .center, spacing: 8) {
                wrapText(maxKey: "wrapTextCanvasTab", key: "defaultColor:")
                Button {
                    viewModel.showColorPopover = true
                } label: {
                    EmptyView()
                }
                .buttonStyle(.color(viewModel.defaultColor))
                .popover(isPresented: $viewModel.showColorPopover, arrowEdge: .bottom) {
                    colorPopover
                }
            }
            .frame(height: 20)
            HStack(alignment: .center) {
                wrapText(maxKey: "wrapTextCanvasTab", key: "defaultOpacity:")
                Text(String(format: "%4.1f", viewModel.defaultOpacity))
                    .font(.system(.body, design: .monospaced))
                Slider(value: $viewModel.defaultOpacity, in: (0.2 ... 1)) { flag in
                    if !flag {
                        viewModel.endUpdatingDefaultOpacity()
                    }
                }
                .frame(height: 20)
                Image(systemName: "checkerboard.rectangle")
                    .frame(height: 20)
                    .opacity(viewModel.defaultOpacity)
            }
            .frame(height: 20)
            HStack(alignment: .center) {
                wrapText(maxKey: "wrapTextCanvasTab", key: "defaultLineWidth:")
                Text(String(format: "%4.1f", viewModel.defaultLineWidth))
                    .font(.system(.body, design: .monospaced))
                Slider(value: $viewModel.defaultLineWidth, in: (1 ... 20)) { flag in
                    if !flag {
                        viewModel.endUpdatingDefaultLineWidth()
                    }
                }
                .frame(height: 20)
                Rectangle()
                    .foregroundColor(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .frame(height: viewModel.defaultLineWidth)
                            .foregroundColor(Color.secondary)
                    )
                    .frame(width: 18, height: 20)
            }
        }
        .fixedSize()
    }

    var colorPopover: some View {
        HStack(spacing: 4) {
            ForEach(0 ..< viewModel.colors.count, id: \.self) { i in
                VStack(spacing: 4) {
                    ForEach(viewModel.colors[i], id: \.hashValue) { color in
                        Button {
                            viewModel.defaultColor = color
                        } label: {
                            EmptyView()
                        }
                        .buttonStyle(.colorPalette(color, Binding<Bool>(
                            get: { viewModel.defaultColor == color },
                            set: { _ in }
                        )))
                    }
                }
            }
        }
        .padding(8)
    }
}

struct CanvasSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["en_US", "ja_JP"], id: \.self) { id in
            CanvasSettingsView(viewModel: PreviewMock.CanvasSettingsViewModelMock())
                .environment(\.locale, .init(identifier: id))
        }
    }
}