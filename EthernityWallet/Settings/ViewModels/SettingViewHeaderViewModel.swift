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
        return R.color.dove()!
    }

    var detailsTextColor: UIColor {
        return R.color.dove()!
    }
    var detailsTextFont: UIFont {
        return Fonts.regular(size: 13)
    }

    var backgroundColor: UIColor {
        return R.color.alabaster()!
    }

    var separatorColor: UIColor {
        return R.color.mercury()!
    }
}

extension SettingViewHeaderViewModel {
    init(section: SettingsSection) {
        titleText = section.title
        switch section {
        case .system, .community:
            titleTextFont = Fonts.semibold(size: 15)
        }
    }
}
