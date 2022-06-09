//
//  AddHideTokenSectionHeaderViewModel.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 01.04.2020.
//

import UIKit

struct AddHideTokenSectionHeaderViewModel {
    let titleText: String
    var separatorColor: UIColor = GroupedTable.Color.cellSeparator
    var titleTextFont: UIFont = Fonts.regular(size: 19)
    var titleTextColor: UIColor = UIColor(hex: "101010")

    var backgroundColor: UIColor = UIColor(hex: "F4F4F4")
    var showTopSeparator: Bool = false
}
