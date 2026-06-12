import DataSource
import SwiftUI

extension Object {
    var color: Color {
        Color.palette(at: paletteIndex).opacity(opacity)
    }

    var path: Path {
        Path(cgPath)
    }

    var strokeStyle: StrokeStyle? {
        switch type {
        case .select, .text, .arrow, .fillRect, .fillOval:
            nil
        case .pen where points.count < 2:
            nil
        case .pen:
            StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
        case .line:
            StrokeStyle(lineWidth: lineWidth, lineCap: .round)
        case .lineRect, .lineOval:
            StrokeStyle(lineWidth: lineWidth)
        }
    }
}
