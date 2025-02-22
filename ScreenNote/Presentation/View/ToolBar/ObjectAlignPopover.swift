/*
  ObjectAlignPopover.swift
  ScreenNote

  Created by Takuto Nakamura on 2023/02/04.
  
*/

import SwiftUI

struct ObjectAlignPopover: View {
    private let toolBarDirection: ToolBarDirection
    private let alignHandler: (AlignMethod) -> Void

    init(
        toolBarDirection: ToolBarDirection,
        alignHandler: @escaping (AlignMethod) -> Void
    ) {
        self.toolBarDirection = toolBarDirection
        self.alignHandler = alignHandler
    }

    var body: some View {
        VStack {
            HStack(spacing: 8) {
                ForEach(AlignMethod.horizontals) { alignMethod in
                    Button {
                        alignHandler(alignMethod)
                    } label: {
                        Image(systemName: alignMethod.symbolName)
                    }
                    .buttonStyle(.toolBar(toolBarDirection))
                    .help(alignMethod.help)
                }
            }
            HStack(spacing: 8) {
                ForEach(AlignMethod.verticals) { alignMethod in
                    Button {
                        alignHandler(alignMethod)
                    } label: {
                        Image(systemName: alignMethod.symbolName)
                    }
                    .buttonStyle(.toolBar(toolBarDirection))
                    .help(alignMethod.help)
                }
            }
        }
        .padding(8)
    }
}

#Preview {
    ObjectAlignPopover(toolBarDirection: .horizontal,
                       alignHandler: { _ in })
}
