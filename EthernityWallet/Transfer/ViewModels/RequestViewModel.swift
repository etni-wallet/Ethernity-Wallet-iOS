// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import UIKit

struct RequestViewModel {
	private let account: Wallet

	init(account: Wallet) {
		self.account = account
	}

	var myAddressText: String {
		return account.address.eip55String
	}

	var myAddress: AlphaWallet.Address {
		return account.address
	}

	var copyWalletText: String {
		return R.string.localizable.requestCopyWalletButtonTitle()
	}
    
    var copyWalletButtonTitle: String {
        return R.string.localizable.aSettingsContentsMyWalletAddressCopyButton()
    }
    
    var shareWalletButtonTitle: String {
        return R.string.localizable.aSettingsContentsMyWalletAddressShareButton()
    }

	var addressCopiedText: String {
		return R.string.localizable.requestAddressCopiedTitle()
	}

	var backgroundColor: UIColor {
		return Colors.appBackground
	}

	var addressLabelColor: UIColor {
        return EthernityColors.ethernityLightGrey
	}

	var copyButtonsFont: UIFont {
		return Fonts.semibold(size: 17)
	}

	var labelColor: UIColor? {
		return R.color.mine()
	}

	var addressFont: UIFont {
		return Fonts.interMedium(size: 16)
	}

	var addressBackgroundColor: UIColor {
		return Colors.appBackground
	}

	var instructionFont: UIFont {
		return Fonts.regular(size: 17)
	}

	var instructionText: String {
		return R.string.localizable.aWalletAddressScanInstructions()
	}
}
