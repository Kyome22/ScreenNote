/*
  ObjectRotatePopover.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/08.
  
*/

import SwiftUI

struct ObjectRotatePopover: View {
    private let toolBarDirection: ToolBarDirection
    private let rotateHandler: (RotateMethod) -> Void

    init(
        toolBarDirection: ToolBarDirection,
        rotateHandler: @escaping (RotateMethod) -> Void
    ) {
        self.toolBarDirection = toolBarDirection
        self.rotateHandler = rotateHandler
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(RotateMethod.allCases, id: \.rawValue) { rotateMethod in
                Button {
                    rotateHandler(rotateMethod)
                } label: {
                    Image(systemName: rotateMethod.symbolName)
                }
                .buttonStyle(.toolBar(toolBarDirection))
                .help(rotateMethod.help)
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
