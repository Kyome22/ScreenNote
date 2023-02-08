/*
  ObjectRotatePopover.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/08.
  
*/

import SwiftUI

struct ObjectRotatePopover: View {
    private let toolBarDirection: ToolBarDirection
    private let rotateHandler: (ObjectRotateDirection) -> Void

    init(
        toolBarDirection: ToolBarDirection,
        rotateHandler: @escaping (ObjectRotateDirection) -> Void
    ) {
        self.toolBarDirection = toolBarDirection
        self.rotateHandler = rotateHandler
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(ObjectRotateDirection.allCases, id: \.rawValue) { rotateDirection in
                Button {
                    rotateHandler(rotateDirection)
                } label: {
                    Image(systemName: rotateDirection.symbolName)
                }
                .buttonStyle(.toolBar(toolBarDirection))
                .help(rotateDirection.help)
            }
        }
        .padding(8)
    }
}

struct ObjectRotatePopover_Previews: PreviewProvider {
    static var previews: some View {
        ObjectRotatePopover(toolBarDirection: .horizontal,
                            rotateHandler: { _ in })
    }
}
