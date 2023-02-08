/*
  ObjectAlignPopover.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/04.
  
*/

import SwiftUI

struct ObjectAlignPopover: View {
    private let toolBarDirection: ToolBarDirection
    private let alignHandler: (ObjectAlignment) -> Void

    init(
        toolBarDirection: ToolBarDirection,
        alignHandler: @escaping (ObjectAlignment) -> Void
    ) {
        self.toolBarDirection = toolBarDirection
        self.alignHandler = alignHandler
    }

    var body: some View {
        VStack {
            HStack(spacing: 8) {
                ForEach(ObjectAlignment.horizontals, id: \.rawValue) { alignment in
                    Button {
                        alignHandler(alignment)
                    } label: {
                        Image(systemName: alignment.symbolName)
                    }
                    .buttonStyle(.toolBar(toolBarDirection))
                    .help(alignment.help)
                }
            }
            HStack(spacing: 8) {
                ForEach(ObjectAlignment.verticals, id: \.rawValue) { alignment in
                    Button {
                        alignHandler(alignment)
                    } label: {
                        Image(systemName: alignment.symbolName)
                    }
                    .buttonStyle(.toolBar(toolBarDirection))
                    .help(alignment.help)
                }
            }
        }
        .padding(8)
    }
}

struct ObjectAlignmentPopover_Previews: PreviewProvider {
    static var previews: some View {
        ObjectAlignPopover(toolBarDirection: .horizontal,
                           alignHandler: { _ in })
    }
}
