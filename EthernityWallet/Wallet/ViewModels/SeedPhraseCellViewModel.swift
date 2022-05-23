// Copyright © 2019 Stormbird PTE. LTD.

import Foundation
import UIKit

struct SeedPhraseCellViewModel {
    let word: String
    let isSelected: Bool
    let index: Int?
    let isSelectable: Bool

    var backgroundColor: UIColor {
        return isSelectable ? UIColor.white : UIColor(red: 249, green: 249, blue: 249)
    }

    var selectedBackgroundColor: UIColor {
        return UIColor(red: 12, green: 134, blue: 255)
    }

    var textColor: UIColor {
        return isSelectable ? UIColor(red: 12, green: 134, blue: 255) : UIColor(red: 109, green: 109, blue: 109)
    }
    
    var borderWidth: CGFloat {
        return isSelectable ? 1.5 : 0.0
    }
    
    var borderColor: UIColor {
        return isSelectable ? UIColor(red: 12, green: 134, blue: 255) : .clear
    }

    var selectedTextColor: UIColor {
        return UIColor(red: 255, green: 255, blue: 255)
    }

    var font: UIFont {
        if ScreenChecker().isNarrowScreen {
            return Fonts.regular(size: 15)
        } else {
            return Fonts.regular(size: 18)
        }
    }

    var sequenceFont: UIFont {
        return Fonts.regular(size: 12)
    }

    var sequenceColor: UIColor {
        return UIColor(red: 109, green: 109, blue: 109)
    }

    var sequence: String? {
        return index.flatMap { String(describing: $0 + 1) }
    }
}
