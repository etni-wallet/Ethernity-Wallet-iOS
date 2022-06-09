//
//  AboutViewModel.swift
//  EthernityWallet
//
//  Created by Bogdan Velesca on 23.05.2022.
//

import UIKit

struct AboutViewModel {
    
    var navigationTitle: String {
        let appName = Bundle.main.appName ?? R.string.localizable.appName()
        let title = R.string.localizable.settingsAboutTitle(appName)
        
        return title
    }

    var appNameAndVersion: NSAttributedString {
        let appName = Bundle.main.appName ?? R.string.localizable.appName()
        let fullVersion = Bundle.main.fullVersion
        
        let style = NSMutableParagraphStyle()
        style.alignment = .left
        let final = String(format: "%@ V.%@", appName, fullVersion)
        return .init(string: final, attributes: [
            .paragraphStyle: style,
            .font: Fonts.regular(size: ScreenChecker().isNarrowScreen ? 11 : 14) as Any,
            .foregroundColor: Colors.black
        ])
    }
    
    
    var appDescription: NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .left

        return .init(string: R.string.localizable.settingsAboutAppDescription(), attributes: [
            .paragraphStyle: style,
            .font: Fonts.regular(size: ScreenChecker().isNarrowScreen ? 12 : 15) as Any,
            .foregroundColor: Colors.black
        ])
    }
    
    var copyright: NSAttributedString {
        let year = Calendar.current.component(.year, from: Date())
        let yearString = "\(year)"
        let copyrightWithYear = R.string.localizable.settingsAboutCopyrights(yearString)
        let style = NSMutableParagraphStyle()
        style.alignment = .left

        return .init(string: copyrightWithYear, attributes: [
            .paragraphStyle: style,
            .font: Fonts.regular(size: ScreenChecker().isNarrowScreen ? 11 : 14) as Any,
            .foregroundColor: Colors.black
        ])
    }
    
    var walletIcon: UIImage {
        return R.image.aboutWalletIcon()!
    }
    
}
