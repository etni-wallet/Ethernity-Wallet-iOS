// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import SwiftUI

struct SettingsViewModel {
    private let account: Wallet

    let blockscanChatUnreadCount: Int?

    func addressReplacedWithENSOrWalletName(_ ensOrWalletName: String? = nil) -> String {
        if let ensOrWalletName = ensOrWalletName {
            return "\(ensOrWalletName) | \(account.address.truncateMiddle)"
        } else {
            return account.address.truncateMiddle
        }
    }

    var passcodeTitle: String {
        switch BiometryAuthenticationType.current {
        case .faceID, .touchID:
            return R.string.localizable.settingsBiometricsEnabledLabelTitle(BiometryAuthenticationType.current.title)
        case .none:
            return R.string.localizable.settingsBiometricsDisabledLabelTitle()
        }
    }

    var localeTitle: String {
        return R.string.localizable.settingsLanguageButtonTitle()
    }

    let sections: [SettingsSection]

    init(account: Wallet, keystore: Keystore, blockscanChatUnreadCount: Int?) {
        self.account = account
        self.blockscanChatUnreadCount = blockscanChatUnreadCount
        sections = SettingsViewModel.functional.computeSections(account: account, keystore: keystore, blockscanChatUnreadCount: blockscanChatUnreadCount)
    }

    func numberOfSections() -> Int {
        return sections.count
    }

    func numberOfSections(in section: Int) -> Int {
        switch sections[section] {
        case .system(let rows):
            return rows.count
        case .community(let rows):
            return rows.count
        }
    }
}

extension SettingsViewModel {
    enum functional {}
}

extension SettingsViewModel.functional {
    fileprivate static func computeSections(account: Wallet, keystore: Keystore, blockscanChatUnreadCount: Int?) -> [SettingsSection] {
        let systemRows: [SettingsSystemRow] = [.passcode, .selectActiveNetworks]
        let communityRows: [SettingsComnmunityRow] = [.telegramCustomer, .discord, .facebook, .twitter, .email, .faq]
        return [
            .system(rows: systemRows),
            .community(rows: communityRows),
        ]
    }
}

enum SettingsWalletRow {
    case showMyWallet
    case changeWallet
    case backup
    case showSeedPhrase
    case walletConnect
    case nameWallet
    case blockscanChat(blockscanChatUnreadCount: Int?)

    var title: String {
        switch self {
        case .showMyWallet:
            return R.string.localizable.settingsShowMyWalletTitle()
        case .changeWallet:
            return R.string.localizable.settingsChangeWalletTitle()
        case .backup:
            return R.string.localizable.settingsBackupWalletButtonTitle()
        case .showSeedPhrase:
            return R.string.localizable.settingsShowSeedPhraseButtonTitle()
        case .walletConnect:
            return R.string.localizable.settingsWalletConnectButtonTitle()
        case .nameWallet:
            return R.string.localizable.settingsWalletRename()
        case .blockscanChat(let blockscanChatUnreadCount):
            if let blockscanChatUnreadCount = blockscanChatUnreadCount, blockscanChatUnreadCount > 0 {
                return "\(R.string.localizable.settingsBlockscanChat()) (\(blockscanChatUnreadCount))"
            } else {
                return R.string.localizable.settingsBlockscanChat()
            }
        }
    }

    var icon: UIImage {
        switch self {
        case .showMyWallet:
            return R.image.walletAddress()!
        case .changeWallet:
            return R.image.changeWallet()!
        case .backup:
            return R.image.backupCircle()!
        case .showSeedPhrase:
            return R.image.iconsSettingsSeed2()!
        case .walletConnect:
            return R.image.iconsSettingsWalletConnect()!
        case .nameWallet:
            return R.image.iconsSettingsDisplayedEns()!
        case .blockscanChat:
            return R.image.settingsBlockscanChat()!
        }
    }
}

enum SettingsSystemRow: CaseIterable {
    case passcode
    case selectActiveNetworks

    var title: String {
        switch self {
        case .passcode:
            return R.string.localizable.settingsPasscodeTitle()
        case .selectActiveNetworks:
            return R.string.localizable.settingsSelectActiveNetworksTitle()
        }
    }

    var icon: UIImage {
        switch self {
        case .passcode:
            return R.image.faceId()!
        case .selectActiveNetworks:
            return R.image.activeNetworks()!
        }
    }
}

enum SettingsSection {
    case system(rows: [SettingsSystemRow])
    case community(rows: [SettingsComnmunityRow])

    var title: String {
        switch self {
        case .system:
            return R.string.localizable.settingsSectionSystemTitle().uppercased()
        case .community:
            return R.string.localizable.settingsSectionCommunityTitle().uppercased()
        }
    }

    var numberOfRows: Int {
        switch self {
        case .system(let rows):
            return rows.count
        case .community(let rows):
            return rows.count
        }
    }
}

enum SettingsComnmunityRow {
    case discord
    case telegramCustomer
    case twitter
    case facebook
    case faq
    case email

    var urlProvider: URLServiceProvider? {
        switch self {
        case .discord:
            return URLServiceProvider.discord
        case .telegramCustomer:
            return URLServiceProvider.telegramCustomer
        case .twitter:
            return URLServiceProvider.twitter
        case .facebook:
            return URLServiceProvider.facebook
        case .faq:
            return URLServiceProvider.faq
        case .email:
            return nil
        }
    }

    var title: String {
        switch self {
        case .discord:
            return URLServiceProvider.discord.title
        case .telegramCustomer:
            return URLServiceProvider.telegramCustomer.title
        case .twitter:
            return URLServiceProvider.twitter.title
        case .facebook:
            return URLServiceProvider.facebook.title
        case .faq:
            return URLServiceProvider.faq.title
        case .email:
            return R.string.localizable.supportEmailTitle()
        }
    }

    var image: UIImage? {
        switch self {
        case .email:
            return R.image.emailCommunity()
        case .discord:
            return URLServiceProvider.discord.image
        case .telegramCustomer:
            return URLServiceProvider.telegramCustomer.image
        case .twitter:
            return URLServiceProvider.twitter.image
        case .facebook:
            return URLServiceProvider.facebook.image
        case .faq:
            return R.image.aboutCommunity()
        }
    }
}
