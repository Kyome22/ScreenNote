/*
 CanvasSettingsView.swift
 ScreenNote

 Created by Takuto Nakamura on 2023/02/08.

 */

import SwiftUI

struct CanvasSettingsView<CVM: CanvasSettingsViewModel>: View {
    @StateObject var viewModel: CVM

    var body: some View {
        Form {
            LabeledContent("objects:") {
                Toggle(isOn: $viewModel.clearAllObjects) {
                    Text("clearAllObjects")
                }
            }
            Divider()
            LabeledContent("defaultColor:") {
                Button("dummy") {
                    viewModel.showColorPopover = true
                }
                .buttonStyle(.color(viewModel.defaultColor))
                .popover(isPresented: $viewModel.showColorPopover, arrowEdge: .bottom) {
                    colorPopover
                }
            }
            Slider(value: $viewModel.defaultOpacity, in: (0.2 ... 1.0)) {
                Text("defaultOpacity:")
            } minimumValueLabel: {
                Text(String(format: "%4.1f", viewModel.defaultOpacity))
                    .font(.system(.body, design: .monospaced))
            } maximumValueLabel: {
                Text(Image(systemName: "checkerboard.rectangle"))
                    .foregroundColor(Color.primary.opacity(viewModel.defaultOpacity))
            } onEditingChanged: { flag in
                if !flag {
                    viewModel.endUpdatingDefaultOpacity()
                }
            }
            HStack(spacing: 0) {
                Slider(value: $viewModel.defaultLineWidth, in: (1 ... 20)) {
                    Text("defaultLineWidth:")
                } minimumValueLabel: {
                    Text(String(format: "%4.1f", viewModel.defaultLineWidth))
                        .font(.system(.body, design: .monospaced))
                } maximumValueLabel: {
                    Text(verbatim: "")
                        .foregroundColor(.clear)
                } onEditingChanged: { flag in
                    if !flag {
                        viewModel.endUpdatingDefaultLineWidth()
                    }
                }
                Rectangle()
                    .foregroundColor(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .frame(height: viewModel.defaultLineWidth)
                            .foregroundColor(Color.secondary)
                    )
                    .frame(width: 18, height: 20)
            }
            Divider()
            LabeledContent("backgroundColor:") {
                HStack(alignment: .center, spacing: 8) {
                    ForEach(viewModel.backgrounds.indices, id: \.self) { index in
                        Button("dummy") {
                            viewModel.updateBackgroundColor(index)
                        }
                        .buttonStyle(.selectableColor(
                            color: viewModel.backgrounds[index],
                            selection: Binding<Bool>(
                                get: { viewModel.backgroundColorIndex == index },
                                set: { _, _ in }
                            )
                        ))
                    }
                }
                .fixedSize()
            }
            Slider(value: $viewModel.backgroundOpacity, in: (0.02 ... 1.0)) {
                Text("backgroundOpacity:")
            } minimumValueLabel: {
                Text(String(format: "%4.2f", viewModel.backgroundOpacity))
                    .font(.system(.body, design: .monospaced))
            } maximumValueLabel: {
                Text(Image(systemName: "checkerboard.rectangle"))
                    .foregroundColor(Color.primary.opacity(viewModel.backgroundOpacity))
            } onEditingChanged: { flag in
                if !flag {
                    viewModel.endUpdatingBackgroundOpacity()
                }
            }
        }
        .formStyle(.columns)
        .fixedSize()
    }

    var colorPopover: some View {
        HStack(spacing: 4) {
            ForEach(viewModel.colors.indices, id: \.self) { i in
                VStack(spacing: 4) {
                    ForEach(viewModel.colors[i].indices, id: \.self) { j in
                        let index = i + 8 * j
                        Button {
                            viewModel.updateDefaultColor(index)
                        } label: {
                            EmptyView()
                        }
                        .buttonStyle(.colorPalette(
                            color: viewModel.colors[i][j],
                            selection: Binding<Bool>(
                                get: { viewModel.defaultColorIndex == index },
                                set: { _ in }
                            )
                        ))
                    }
                }
            }
        }
        .padding(8)
    }
}

#Preview {
    ForEach(["en_US", "ja_JP"], id: \.self) { id in
        CanvasSettingsView(viewModel: PreviewMock.CanvasSettingsViewModelMock())
            .environment(\.locale, .init(identifier: id))
    }
}
