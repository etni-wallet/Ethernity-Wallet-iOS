// Copyright © 2018 Stormbird PTE. LTD.

import Foundation

enum WalletFilter: Equatable {
	case all
    case type(Set<TokenType>)
    case defi
    case governance
    case assets
    case transactions
	case collectiblesOnly
	case keyword(String)
}
