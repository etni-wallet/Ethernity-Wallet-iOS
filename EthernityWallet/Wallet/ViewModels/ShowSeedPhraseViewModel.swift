// Copyright © 2019 Stormbird PTE. LTD.

import Foundation
import UIKit

struct ShowSeedPhraseViewModel {
    private let error: KeystoreError?

    let words: [String]
    
    var step: String = R.string.localizable.walletsShowSeedPhraseSubtitleStepOne()
    var subtitle: String = R.string.localizable.walletsShowSeedPhraseSubtitle()

    var attributedSubtitle: NSAttributedString {
        
        let attributeString = NSMutableAttributedString(string: step + subtitle)
        let style = NSMutableParagraphStyle()
        style.alignment = .center

        attributeString.addAttributes([
            .paragraphStyle: style,
            .font: Screen.Backup.subtitleFont,
            .foregroundColor: R.color.black()!
        ], range: NSRange(location: step.count, length: subtitle.count))
        attributeString.addAttributes([
            .paragraphStyle: style,
            .font: Screen.Backup.subtitleFont,
            .foregroundColor: R.color.electricBlueLightest()!
        ], range: NSRange(location: 0, length: step.count))
        
        return attributeString
    }
    
    var buttonTitle: String = R.string.localizable.walletsShowSeedPhraseTestSeedPhrase()
    
    var navBarTitle: String {
        return R.string.localizable.backupWalletIntroductionNavTitle()
    }
    
    var subtitleColor: UIColor {
        return Screen.Backup.subtitleColor
    }

    var subtitleFont: UIFont {
        return Screen.Backup.subtitleFont
    }

    var errorColor: UIColor {
        return Colors.appRed
    }

    var errorFont: UIFont {
        return Fonts.regular(size: 18)
    }

    var errorMessage: String? {
        return error?.errorDescription
    }

    init(words: [String]) {
        self.words = words
        self.error = nil
    }

    init(error: KeystoreError) {
        self.words = []
        self.error = error
    }
}
