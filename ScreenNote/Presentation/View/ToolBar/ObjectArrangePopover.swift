/*
  ObjectArrangePopover.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/04.
  
*/

import SwiftUI

struct ObjectArrangePopover: View {
    private let toolBarDirection: ToolBarDirection
    private let arrangeHandler: (ObjectArrangeMethod) -> Void

    init(
        toolBarDirection: ToolBarDirection,
        arrangeHandler: @escaping (ObjectArrangeMethod) -> Void
    ) {
        self.toolBarDirection = toolBarDirection
        self.arrangeHandler = arrangeHandler
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(ObjectArrangeMethod.allCases, id: \.rawValue) { arrangeMethod in
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

struct ObjectArrangePopover_Previews: PreviewProvider {
    static var previews: some View {
        ObjectArrangePopover(toolBarDirection: .horizontal,
                             arrangeHandler: { _ in })
    }
}
