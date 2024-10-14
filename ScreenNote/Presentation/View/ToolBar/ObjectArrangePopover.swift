/*
  ObjectArrangePopover.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/04.
  
*/

import SwiftUI

struct ObjectArrangePopover: View {
    private let toolBarDirection: ToolBarDirection
    private let arrangeHandler: (ArrangeMethod) -> Void

    init(
        toolBarDirection: ToolBarDirection,
        arrangeHandler: @escaping (ArrangeMethod) -> Void
    ) {
        self.toolBarDirection = toolBarDirection
        self.arrangeHandler = arrangeHandler
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(ArrangeMethod.allCases) { arrangeMethod in
                Button {
                    arrangeHandler(arrangeMethod)
                } label: {
                    Image(systemName: arrangeMethod.symbolName)
                }
                .buttonStyle(.toolBar(toolBarDirection))
                .help(arrangeMethod.help)
            }
        }
        .padding(8)
    }
}

#Preview {
    ObjectArrangePopover(toolBarDirection: .horizontal,
                         arrangeHandler: { _ in })
}
