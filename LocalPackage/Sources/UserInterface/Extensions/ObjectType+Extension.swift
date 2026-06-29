import DataSource
import SwiftUI

extension ObjectType {
    var symbolName: String {
        switch self {
        case .select:
            "hand.point.up.left.fill"
        case .text:
            "textbox"
        case .pen:
            "scribble"
        case .line:
            "line.diagonal"
        case .arrow:
            "line.diagonal.arrow"
        case .fillRect:
            "square.fill"
        case .lineRect:
            "square"
        case .fillOval:
            "oval.fill"
        case .lineOval:
            "oval"
        }
    }

    var label: String {
        let localizationValue: String.LocalizationValue = switch self {
        case .select:
            "toolSelect"
        case .text:
            "toolText"
        case .pen:
            "toolPen"
        case .line:
            "toolLine"
        case .arrow:
            "toolArrow"
        case .fillRect:
            "toolFillRect"
        case .lineRect:
            "toolLineRect"
        case .fillOval:
            "toolFillOval"
        case .lineOval:
            "toolLineOval"
        }
        return String(localized: localizationValue, bundle: .module)
    }

    var help: String {
        let localizationValue: String.LocalizationValue = switch self {
        case .select:
            "helpSelect"
        case .text:
            "helpText"
        case .pen:
            "helpPen"
        case .line:
            "helpLine"
        case .arrow:
            "helpArrow"
        case .fillRect:
            "helpFillRect"
        case .lineRect:
            "helpLineRect"
        case .fillOval:
            "helpFillOval"
        case .lineOval:
            "helpLineOval"
        }
        return String(localized: localizationValue, bundle: .module)
    }

    var key: KeyEquivalent {
        switch self {
        case .select:
            "s"
        case .text:
            "t"
        case .pen:
            "p"
        case .line:
            "l"
        case .arrow:
            "a"
        case .fillRect:
            "r"
        case .lineRect:
            "R"
        case .fillOval:
            "o"
        case .lineOval:
            "O"
        }
    }

    var modifiers: EventModifiers {
        switch self {
        case .select, .text, .pen, .line, .arrow,.fillRect, .fillOval:
            []
        case .lineRect, .lineOval:
            [.shift]
        }
    }
}
