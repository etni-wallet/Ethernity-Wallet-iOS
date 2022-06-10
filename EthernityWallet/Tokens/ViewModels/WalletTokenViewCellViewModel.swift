//
//  WalletTokenViewCellViewModel.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 07.06.2021.
//

import UIKit
import BigInt

struct WalletTokenViewCellViewModel {
    private let shortFormatter = EtherNumberFormatter.short
    private let token: TokenObject
    private let assetDefinitionStore: AssetDefinitionStore
    let isVisible: Bool

    init(token: TokenObject, assetDefinitionStore: AssetDefinitionStore, isVisible: Bool = true) {
        self.token = token
        self.assetDefinitionStore = assetDefinitionStore
        self.isVisible = isVisible
    }

    private var title: String {
        return token.titleInPluralForm(withAssetDefinitionStore: assetDefinitionStore)
    }

    private var amount: String {
        return shortFormatter.string(from: token.valueBigInt, decimals: token.decimals)
    }

    var cryptoValueAttributedString: NSAttributedString {
        return NSAttributedString(string: String(), attributes: [
            .foregroundColor: Screen.TokenCard.Color.title,
            .font: Screen.TokenCard.Font.title
        ])
    }

    var backgroundColor: UIColor {
        return Screen.TokenCard.Color.background
    }

    var contentsBackgroundColor: UIColor {
        return Screen.TokenCard.Color.background
    }

    var titleAttributedString: NSAttributedString {
        return NSAttributedString(string: title, attributes: [
            .foregroundColor: Screen.TokenCard.Color.title,
            .font: Fonts.regular(size: 16)//Screen.TokenCard.Font.title
        ])
    }

    var alpha: CGFloat {
        return isVisible ? 1.0 : 1.0
    }

    var iconImage: Subscribable<TokenImage> {
        token.icon(withSize: .s300)
    }

    var blockChainTagViewModel: BlockchainTagLabelViewModel {
        return .init(server: token.server)
    }
}
