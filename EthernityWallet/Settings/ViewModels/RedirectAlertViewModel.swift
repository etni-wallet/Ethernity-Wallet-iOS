//
//  RedirectAlertViewModel.swift
//  EthernityWallet
//
//  Created by Bogdan Velesca on 25.05.2022.
//

import UIKit

struct RedirectAlertViewModel {
    let urlServiceProvider: URLServiceProvider
    
    init(urlServiceProvider: URLServiceProvider) {
        self.urlServiceProvider = urlServiceProvider
    }
    
    var titleString: NSAttributedString {
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        return .init(string: R.string.localizable.settingsRedirectUrlModalTitle(), attributes: [
            .font: Fonts.semibold(size: ScreenChecker().isNarrowScreen ? 11 : 14),
            .foregroundColor: Colors.black,
            .paragraphStyle: paragraphStyle
        ])
    }
    
    var appNameAttributedString: NSAttributedString {
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        return .init(string: urlServiceProvider.title, attributes: [
            .font: Fonts.bold(size: ScreenChecker().isNarrowScreen ? 11 : 14),
            .foregroundColor: EthernityColors.electricBlueLight,
            .paragraphStyle: paragraphStyle
        ])
    }
    
    var cancelString: NSAttributedString {
        return .init(string: R.string.localizable.settingsRedirectUrlModalCancel(), attributes: [
            .font: Fonts.regular(size: ScreenChecker().isNarrowScreen ? 11 : 14),
            .foregroundColor: EthernityColors.electricYellow
        ])
    }
    
    var allowString: NSAttributedString {
        return .init(string: R.string.localizable.settingsRedirectUrlModalOk(), attributes: [
            .font: Fonts.regular(size: ScreenChecker().isNarrowScreen ? 11 : 14),
            .foregroundColor: Colors.appWhite
        ])
    }
    
    var cancelButtonBorderWidth: CGFloat {
        return 1.0
    }
    
    var cancelButtonBorderColor: UIColor {
        return EthernityColors.electricYellow
    }
    
    var cancelButtonBackgroundColor: UIColor {
        return Colors.appWhite
    }
    
    var cancelButtonCornerRadius: CGFloat {
        return 6
    }
    
    var allowButtonBackgroundColor: UIColor {
        return EthernityColors.electricYellow
    }
    
    var allowButtonCornerRadius: CGFloat {
        return 6
    }
}
