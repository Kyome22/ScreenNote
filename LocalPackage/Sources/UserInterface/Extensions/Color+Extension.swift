import SwiftUI

extension Color {
    static var palette: [[Color]] {
        NSColor.primaries.map { primary in
            (0 ..< 5).map { shade in
                Color(primary.blended(withFraction: 0.2 * CGFloat(shade), of: .black)!)
            }
        }
    }

    static func palette(at index: Int) -> Color {
        palette[index % 8][index / 8]
    }
}
