/*
  ObjectFlipPopover.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/08.
  
*/

import SwiftUI

struct ObjectFlipPopover: View {
    private let toolBarDirection: ToolBarDirection
    private let flipHandler: (ObjectFlipDirection) -> Void

    init(
        toolBarDirection: ToolBarDirection,
        flipHandler: @escaping (ObjectFlipDirection) -> Void
    ) {
        self.toolBarDirection = toolBarDirection
        self.flipHandler = flipHandler
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(ObjectFlipDirection.allCases, id: \.rawValue) { flipDirection in
                Button {
                    flipHandler(flipDirection)
                } label: {
                    Image(systemName: flipDirection.symbolName)
                }
                .buttonStyle(.toolBar(toolBarDirection))
                .help(flipDirection.help)
            }
        }
        .padding(8)
    }
}

struct ObjectFlipPopover_Previews: PreviewProvider {
    static var previews: some View {
        ObjectFlipPopover(toolBarDirection: .horizontal,
                          flipHandler: { _ in })
    }
}
