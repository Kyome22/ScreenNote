import DataSource
import Foundation

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
}
