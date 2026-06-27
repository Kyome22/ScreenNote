import DataSource
import SwiftUI

extension TextOrientation {
    var angle: Angle {
        switch self {
        case .up, .upMirrored:
            Angle(degrees: 0)
        case .right, .rightMirrored:
            Angle(degrees: 90)
        case .down, .downMirrored:
            Angle(degrees: 180)
        case .left, .leftMirrored:
            Angle(degrees: 270)
        }
    }

    var scale: CGFloat {
        switch self {
        case .up, .right, .down, .left:
            1.0
        case .upMirrored, .rightMirrored, .downMirrored, .leftMirrored:
            -1.0
        }
    }
}
