import SwiftUI

struct DefaultColorPopover: View {
    var currentIndex: Int
    var onSelectColor: (Int) async -> Void

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Color.palette.indices, id: \.self) { column in
                VStack(spacing: 4) {
                    ForEach(Color.palette[column].indices, id: \.self) { row in
                        let index = column + 8 * row
                        Button {
                            Task {
                                await onSelectColor(index)
                            }
                        } label: {
                            EmptyView()
                        }
                        .buttonStyle(.colorPalette(
                            color: Color.palette[column][row],
                            selection: currentIndex == index
                        ))
                    }
                }
            }
        }
        .padding(8)
    }
}
