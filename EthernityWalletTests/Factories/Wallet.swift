// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import AlphaWallet

extension Wallet {
    static func make(type: WalletType = .real(.make())) -> Wallet {
        return Wallet(type: type)
    }

    static func makeStormBird(type: WalletType = .real(AlphaWallet.Address(string: "0x007bEe82BDd9e866b2bd114780a47f2261C684E3")!)) -> Wallet {
        return Wallet(type: type)
    }
}
