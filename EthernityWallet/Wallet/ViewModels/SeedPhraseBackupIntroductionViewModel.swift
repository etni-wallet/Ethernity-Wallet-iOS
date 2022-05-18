// Copyright © 2019 Stormbird PTE. LTD.

import Foundation
import UIKit

struct SeedPhraseBackupIntroductionViewModel {
    var backgroundColor: UIColor {
        return Colors.appWhite
    }

    var title: String {
        return R.string.localizable.walletsBackupHdWalletIntroductionButtonTitle()
    }
    
    var navBarTitle: String {
        return R.string.localizable.backupWalletIntroductionNavTitle()
    }

    var imageViewImage: UIImage {
        return R.image.backupWalletIntroIcon()!
    }
    
    var attributedSubtitle: NSAttributedString {
        let subtitle = R.string.localizable.walletsBackupHdWalletIntroductionTitle()
        let attributeString = NSMutableAttributedString(string: subtitle)
        let style = NSMutableParagraphStyle()
        style.alignment = .center

        attributeString.addAttributes([
            .paragraphStyle: style,
            .font: Screen.Backup.subtitleFont,
            .foregroundColor: R.color.black()!
        ], range: NSRange(location: 0, length: subtitle.count))
        
        return attributeString
    }
    
    var attributedDescription: NSAttributedString {
        let description = R.string.localizable.walletsBackupHdWalletIntroductionDescription()
        let attributeString = NSMutableAttributedString(string: description)
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineSpacing = ScreenChecker.size(big: 18, medium: 14, small: 7)
        
        attributeString.addAttributes([
            .paragraphStyle: style,
            .font: Screen.Backup.descriptionFont,
            .foregroundColor: Colors.appText
        ], range: NSRange(location: 0, length: description.count))
        
        return attributeString
    } 
}
