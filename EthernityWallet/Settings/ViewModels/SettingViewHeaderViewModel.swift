//
//  SettingViewHeaderViewModel.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 02.06.2020.
//

import UIKit

struct SettingViewHeaderViewModel {
    let titleText: String
    var detailsText: String?
    var titleTextFont: UIFont
    var showTopSeparator: Bool = true

    var titleTextColor: UIColor {
        return UIColor(hex: "101010")
    }

    var detailsTextColor: UIColor {
        return UIColor(hex: "101010")
    }
    var detailsTextFont: UIFont {
        return Fonts.regular(size: 13)
    }

    var backgroundColor: UIColor {
        return .white
    }

    var separatorColor: UIColor {
        return .white
    }
}

extension SettingViewHeaderViewModel {
    init(section: SettingsSection) {
        titleText = section.title
        switch section {
        case .system, .community:
            titleTextFont = Fonts.semibold(size: 17)
        }
    }
}
