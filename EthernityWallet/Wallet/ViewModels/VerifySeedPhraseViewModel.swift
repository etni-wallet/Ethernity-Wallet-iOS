// Copyright © 2019 Stormbird PTE. LTD.

import Foundation
import UIKit

struct VerifySeedPhraseViewModel {
    var backgroundColor: UIColor {
        return Colors.appWhite
    }

    var attributedTitle: NSAttributedString {
        
        let attributeString = NSMutableAttributedString(string: step + title)
        let style = NSMutableParagraphStyle()
        style.alignment = .center

        attributeString.addAttributes([
            .paragraphStyle: style,
            .font: Screen.Backup.subtitleFont,
            .foregroundColor: R.color.black()!
        ], range: NSRange(location: step.count, length: title.count))
        attributeString.addAttributes([
            .paragraphStyle: style,
            .font: Screen.Backup.subtitleFont,
            .foregroundColor: R.color.electricBlueLightest()!
        ], range: NSRange(location: 0, length: step.count))
        
        return attributeString
    }
    
    var step: String = R.string.localizable.walletsVerifySeedPhraseTitleStepTwo()
    var title: String = R.string.localizable.walletsVerifySeedPhraseTitle()
    
    var navBarTitle: String {
        return R.string.localizable.backupWalletIntroductionNavTitle()
    }

    var seedPhraseTextViewBorderNormalColor: UIColor {
        return R.color.electricBlueLightest()!
    }

    var seedPhraseTextViewBorderErrorColor: UIColor {
        return Colors.appRed
    }

    var seedPhraseTextViewBorderWidth: CGFloat {
        return 3
    }

    var seedPhraseTextViewBorderCornerRadius: CGFloat {
        return 6
    }

    var seedPhraseTextViewFont: UIFont {
        return Fonts.regular(size: 20)
    }

    var seedPhraseTextViewContentInset: UIEdgeInsets {
        return .init(top: 0, left: 7, bottom: 0, right: 7)
    }

    var errorColor: UIColor {
        return Colors.appRed
    }

    //Make it the same as the background. Trick to maintain the height of the error label even when there's no error by putting some dummy text. The dummy text must still make sense for accessibility
    var noErrorColor: UIColor {
        return backgroundColor
    }

    var errorFont: UIFont {
        return Fonts.regular(size: 18)
    }

    var noErrorText: String {
        //Don't need to localize. But still good to, for accessibility
        return "No error"
    }

    var importKeystoreJsonButtonFont: UIFont {
        return Fonts.regular(size: 20)
    }

    var subtitleColor: UIColor {
        return Screen.Backup.subtitleColor
    }

    var subtitleFont: UIFont {
        return Screen.Backup.subtitleFont
    }
}
