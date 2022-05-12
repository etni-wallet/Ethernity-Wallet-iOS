//
//  DefaultsWalletAddressesStore.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 22.01.2022.
//

import Foundation
import Combine

struct DefaultsWalletAddressesStore: WalletAddressesStore {
    var walletsPublisher: AnyPublisher<Set<Wallet>, Never> {
        walletsSubject.eraseToAnyPublisher()
    }

    private var walletsSubject: CurrentValueSubject<Set<Wallet>, Never> = .init([])

    private struct Keys {
        static let watchAddresses = "watchAddresses"
        static let ethereumAddressesWithPrivateKeys = "ethereumAddressesWithPrivateKeys"
        static let ethereumAddressesWithSeed = "ethereumAddressesWithSeed"
        static let ethereumAddressesProtectedByUserPresence = "ethereumAddressesProtectedByUserPresence"
    }
    let userDefaults: UserDefaults
    var hasWallets: Bool {
        return !wallets.isEmpty
    }

    var hasMigratedFromKeystoreFiles: Bool {
        return userDefaults.data(forKey: Keys.ethereumAddressesWithPrivateKeys) != nil
    }

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    //This might not work correctly (since it doesn't read or store the wallet) if we switch back to this class (but we shouldn't because we use it for migrating away from the old wallet storage)
    var recentlyUsedWallet: Wallet?

    var wallets: [Wallet] {
        let watchAddresses = self.watchAddresses.compactMap { AlphaWallet.Address(string: $0) }.map { Wallet(type: .watch($0)) }
        let addressesWithPrivateKeys = ethereumAddressesWithPrivateKeys.compactMap { AlphaWallet.Address(string: $0) }.map { Wallet(type: .real($0)) }
        let addressesWithSeed = ethereumAddressesWithSeed.compactMap { AlphaWallet.Address(string: $0) }.map { Wallet(type: .real($0)) }
        return addressesWithSeed + addressesWithPrivateKeys + watchAddresses
    }

    var watchAddresses: [String] {
        get {
            return userDefaults.data(forKey: Keys.watchAddresses)
                .flatMap { try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData($0) as? [String] }
                .flatMap { $0 } ?? []
        }
        set {
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true) else { return }
            userDefaults.set(data, forKey: Keys.watchAddresses)
        }
    }

    var ethereumAddressesWithPrivateKeys: [String] {
        get {
            return userDefaults.data(forKey: Keys.ethereumAddressesWithPrivateKeys)
                .flatMap { try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData($0) as? [String] }
                .flatMap { $0 } ?? []
        }
        set {
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true) else { return }
            userDefaults.set(data, forKey: Keys.ethereumAddressesWithPrivateKeys)
        }
    }

    var ethereumAddressesWithSeed: [String] {
        get {
            return userDefaults.data(forKey: Keys.ethereumAddressesWithSeed)
                .flatMap { try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData($0) as? [String] }
                .flatMap { $0 } ?? []
        }
        set {
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true) else { return }
            userDefaults.set(data, forKey: Keys.ethereumAddressesWithSeed)
        }
    }

    var ethereumAddressesProtectedByUserPresence: [String] {
        get {
            return userDefaults.data(forKey: Keys.ethereumAddressesProtectedByUserPresence)
                .flatMap { try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData($0) as? [String] }
                .flatMap { $0 } ?? []
        }
        set {
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: true) else { return }
            userDefaults.set(data, forKey: Keys.ethereumAddressesProtectedByUserPresence)
        }
    }

    private var didAddWalletSubject: PassthroughSubject<AlphaWallet.Address, Never> = .init()
    private var didRemoveWalletSubject: PassthroughSubject<Wallet, Never> = .init()

    var didAddWalletPublisher: AnyPublisher<AlphaWallet.Address, Never> {
        didAddWalletSubject.eraseToAnyPublisher()
    }

    var didRemoveWalletPublisher: AnyPublisher<Wallet, Never> {
        didRemoveWalletSubject.eraseToAnyPublisher()
    }

    mutating func addToListOfWatchEthereumAddresses(_ address: AlphaWallet.Address) {
        watchAddresses = [watchAddresses, [address.eip55String]].flatMap { $0 }

        didAddWalletSubject.send(address)
    }

    mutating func addToListOfEthereumAddressesWithPrivateKeys(_ address: AlphaWallet.Address) {
        let updatedOwnedAddresses = Array(Set(ethereumAddressesWithPrivateKeys + [address.eip55String]))
        ethereumAddressesWithPrivateKeys = updatedOwnedAddresses

        didAddWalletSubject.send(address)
    }

    mutating func addToListOfEthereumAddressesWithSeed(_ address: AlphaWallet.Address) {
        let updated = Array(Set(ethereumAddressesWithSeed + [address.eip55String]))
        ethereumAddressesWithSeed = updated

        didAddWalletSubject.send(address)
    }

    mutating func addToListOfEthereumAddressesProtectedByUserPresence(_ address: AlphaWallet.Address) {
        let updated = Array(Set(ethereumAddressesProtectedByUserPresence + [address.eip55String]))
        ethereumAddressesProtectedByUserPresence = updated

        didAddWalletSubject.send(address)
    }

    mutating func removeAddress(_ account: Wallet) {
        ethereumAddressesWithPrivateKeys = ethereumAddressesWithPrivateKeys.filter { $0 != account.address.eip55String }
        ethereumAddressesWithSeed = ethereumAddressesWithSeed.filter { $0 != account.address.eip55String }
        ethereumAddressesProtectedByUserPresence = ethereumAddressesProtectedByUserPresence.filter { $0 != account.address.eip55String }
        watchAddresses = watchAddresses.filter { $0 != account.address.eip55String }

        didRemoveWalletSubject.send(account)
    }
}
