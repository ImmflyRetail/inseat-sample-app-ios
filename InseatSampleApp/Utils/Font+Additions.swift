import SwiftUI
import UIKit

extension Font {

    enum InseatFontWeight: String {
        case bold               = "Bold"
        case regular            = "Regular"
        case semibold           = "SemiBold"
    }

    static func appFont(size: CGFloat, weight: InseatFontWeight = .regular) -> Font {
        return custom("Rubik-\(weight.rawValue)", size: size)
    }
}
