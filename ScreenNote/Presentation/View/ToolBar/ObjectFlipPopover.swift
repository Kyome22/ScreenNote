/*
  ObjectFlipPopover.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/08.
  
*/

import SwiftUI

struct ObjectFlipPopover: View {
    private let toolBarDirection: ToolBarDirection
    private let flipHandler: (FlipMethod) -> Void

    init(
        toolBarDirection: ToolBarDirection,
        flipHandler: @escaping (FlipMethod) -> Void
    ) {
        self.toolBarDirection = toolBarDirection
        self.flipHandler = flipHandler
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(FlipMethod.allCases, id: \.rawValue) { flipMethod in
                Button {
                    flipHandler(flipMethod)
                } label: {
                    Image(systemName: flipMethod.symbolName)
                }
                .buttonStyle(.toolBar(toolBarDirection))
                .help(flipMethod.help)
            }
        }
        .padding(8)
    }
}

#Preview {
    ObjectFlipPopover(toolBarDirection: .horizontal,
                      flipHandler: { _ in })
}
