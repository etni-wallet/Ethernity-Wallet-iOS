// Copyright SIX DAY LLC. All rights reserved.

import UIKit

struct ImportWalletViewModel {
    //Must be computed because localization can be overridden by user dynamically
    static var segmentedControlTitles: [String] { ImportWalletTab.orderedTabs.map { $0.title } }

    var backgroundColor: UIColor {
        return Colors.appBackground
    }

    var title: String {
        return R.string.localizable.importNavigationTitle()
    }

    var mnemonicLabel: String {
        return R.string.localizable.mnemonic().uppercased()
    }

    var mnemonicPlaceholder: String {
        return R.string.localizable.mnemonicPlaceholder()
    }
    
    var keystoreJSONLabel: String {
        return R.string.localizable.keystoreJSON().uppercased()
    }
    
    var keystoreJSONPlaceholder: String {
        return R.string.localizable.keystoreJSONPlaceholder()
    }

    var passwordLabel: String {
        return R.string.localizable.password().uppercased()
    }
    
    var passwordPlaceholder: String {
        return R.string.localizable.enterPassword()
    }

    var privateKeyLabel: String {
        return R.string.localizable.privateKey().uppercased()
    }
    
    var privateKeyPlaceholder: String {
        return R.string.localizable.privateKeyPlaceholder()
    }

    var watchAddressLabel: String {
        return R.string.localizable.ethereumAddress().uppercased()
    }

    var importKeystoreJsonButtonFont: UIFont {
        return Fonts.regular(size: ScreenChecker().isNarrowScreen ? 16 : 20)
    }

    var importSeedAttributedText: NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .natural

        return .init(string: R.string.localizable.importWalletImportSeedPhraseDescription(), attributes: [
            .paragraphStyle: style,
            .font: Fonts.regular(size: ScreenChecker().isNarrowScreen ? 12 : 14),
            .foregroundColor: UIColor(red: 16, green: 16, blue: 16)
        ])
    }
    
    var passwordPlaceholderAttributedText: NSAttributedString {
        return .init(string: R.string.localizable.enterPassword(), attributes: [
            .font: Fonts.regular(size: ScreenChecker().isNarrowScreen ? 12 : 14),
            .foregroundColor: UIColor(red: 109, green: 109, blue: 109)
        ])
    }
    
    func convertSegmentedControlSelectionToFilter(_ selection: ControlSelection) -> ImportWalletTab? {
        switch selection {
        case .selected(let index):
            return ImportWalletTab.filter(fromIndex: UInt(index))
        case .unselected:
            return nil
        }
    }
}

extension ImportWalletTab {
    static var orderedTabs: [ImportWalletTab] {
        return [
            .mnemonic,
            .keystore,
            .privateKey,
            //.watch,
        ]
    }

    static func filter(fromIndex index: UInt) -> ImportWalletTab? {
        return ImportWalletTab.orderedTabs.first { $0.selectionIndex == index }
    }

    var title: String {
        switch self {
        case .mnemonic:
            return R.string.localizable.mnemonicShorter()
        case .keystore:
            return ImportSelectionType.keystore.title
        case .privateKey:
            return ImportSelectionType.privateKey.title
        case .watch:
            return ImportSelectionType.watch.title
        }
    }

    var selectionIndex: UInt {
        //This is safe only because index can't possibly be negative
        return UInt(ImportWalletTab.orderedTabs.firstIndex(of: self) ?? 0)
    }
}
