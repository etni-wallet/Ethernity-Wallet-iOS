//
//  AccountWalletCollectionViewCellViewModel.swift
//  EthernityWallet
//
//  Created by Bogdan Velesca on 03.06.2022.
//

import UIKit

struct AccountWalletCollectionViewCellViewModel {
    var accountTitleFont: UIFont {
        return Fonts.regular(size: 18)
    }
    
    var amountFont: UIFont {
        return Fonts.light(size: 24)
    }
    
    let accountTitle: String
    let walletAddress: String
    let amount: Double
}
