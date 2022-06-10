//
//  AccountWalletCollectionViewCell.swift
//  EthernityWallet
//
//  Created by Bogdan Velesca on 02.06.2022.
//

import UIKit

protocol AccountWalletCollectionViewCellDelegate: AnyObject {
    func accountWalletCollectionViewCellDidTapCopyButton(indexPath: IndexPath)
    func accountWalletCollectionViewCellDidTapSend(indexPath: IndexPath)
    func accountWalletCollectionViewCellDidTapReceive(indexPath: IndexPath)
    func accountWalletCollectionViewCellDidTapMoreButton(indexPath: IndexPath)
}

protocol AccountWalletcollectionViewCellDisplayLogic {
    func configure(viewModel: AccountWalletCollectionViewCellViewModel)
}

class AccountWalletCollectionViewCell: UICollectionViewCell {
    
    private let background: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12.0
        
        return view
    }()
    private let backgroundImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = R.image.walletCards()!
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.layer.cornerRadius = 12.0
        imgView.contentMode = .scaleToFill
        
        return imgView
    }()
    private let accountTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        
        return label
    }()
    private let amount: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        
        return label
    }()
    private let walletAddress: WalletAddressCustomView = {
        let view = WalletAddressCustomView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    private let sendButton: SendReceiveButton = {
        let button = SendReceiveButton(type: .send)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let receiveButton: SendReceiveButton = {
        let button = SendReceiveButton(type: .receive)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let moreButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(R.image.moreIcon()!, for: .normal)
        return button
    }()
    
    weak var delegate: AccountWalletCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.isUserInteractionEnabled = true
        background.isUserInteractionEnabled = true
        sendButton.delegate = self
        receiveButton.delegate = self
        
        contentView.backgroundColor = .clear
        background.backgroundColor = .clear
        
        contentView.addSubview(background)
        
        background.addSubview(backgroundImageView)
        background.addSubview(accountTitle)
        background.addSubview(walletAddress)
        background.addSubview(amount)
        background.addSubview(sendButton)
        background.addSubview(receiveButton)
        background.addSubview(moreButton)
        
        NSLayoutConstraint.activate([
            background.anchorsConstraint(to: contentView),
            backgroundImageView.anchorsConstraint(to: background),
            
            accountTitle.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 23.0),
            accountTitle.topAnchor.constraint(equalTo: background.topAnchor, constant: 23.0),
            
            amount.centerYAnchor.constraint(equalTo: accountTitle.centerYAnchor),
            amount.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -28.0),
            
            walletAddress.leadingAnchor.constraint(equalTo: accountTitle.leadingAnchor),
            walletAddress.topAnchor.constraint(equalTo: accountTitle.bottomAnchor, constant: 8.0),
            
//            sendButton.topAnchor.constraint(equalTo: walletAddress.bottomAnchor, constant: 40),
            sendButton.leadingAnchor.constraint(equalTo: accountTitle.leadingAnchor),
            sendButton.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -12.0),
//            sendButton.heightAnchor.constraint(equalToConstant: 41.0),
            
            receiveButton.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),
            receiveButton.leadingAnchor.constraint(equalTo: sendButton.trailingAnchor, constant: 18.0),
//            receiveButton.heightAnchor.constraint(equalToConstant: 41.0),
            
            moreButton.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor),
            moreButton.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -28.0)
            
        ])

        
        moreButton.addTarget(self, action: #selector(moreButtonTapped(sender:)), for: .touchUpInside)
    }
    
    @objc func moreButtonTapped(sender: UIButton) {
        delegate?.accountWalletCollectionViewCellDidTapMoreButton(indexPath: indexPath!)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AccountWalletCollectionViewCell: AccountWalletcollectionViewCellDisplayLogic {
    func configure(viewModel: AccountWalletCollectionViewCellViewModel) {
        accountTitle.font = viewModel.accountTitleFont
        accountTitle.text = "Main Account"
        amount.font = viewModel.amountFont
        amount.text = "$310.000"
        
        walletAddress.configure(walletAddress: "0xRdad274..ETNY")
    }
}

extension AccountWalletCollectionViewCell: SendReceiveButtonDelegate {
    func sendReceiveButtonTapped(type: SendReceiveButtonType) {
        switch(type) {
        case .receive:
            delegate?.accountWalletCollectionViewCellDidTapReceive(indexPath: indexPath!)
        case .send:
            delegate?.accountWalletCollectionViewCellDidTapSend(indexPath: indexPath!)
        }
    }
}

extension AccountWalletCollectionViewCell: WalletAddressCustomViewDelegate {
    func walletAddressCustomViewDelegateDidTapCopyButton() {
        delegate?.accountWalletCollectionViewCellDidTapCopyButton(indexPath: indexPath!)
    }
}

fileprivate protocol WalletAddressCustomViewDisplayLogic: AnyObject {
    func configure(walletAddress: String)
}

fileprivate class WalletAddressCustomView: UIControl, WalletAddressCustomViewDisplayLogic {
    private let semiTransparentBackground = UIView()
    private var copyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = R.image.copyIcon()!
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    private let walletAddressLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.regular(size: 16.0)
        
        return label
    }()
    
    weak var delegate: WalletAddressCustomViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        semiTransparentBackground.translatesAutoresizingMaskIntoConstraints = false
        addSubview(semiTransparentBackground)
        semiTransparentBackground.backgroundColor = R.color.walletAddressBackground()
        semiTransparentBackground.alpha = 0.4
        semiTransparentBackground.layer.cornerRadius = 3.0
        
        walletAddressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(copyImageView)
        addSubview(walletAddressLabel)
        NSLayoutConstraint.activate([
            semiTransparentBackground.anchorsConstraint(to: self),
            
            walletAddressLabel.topAnchor.constraint(equalTo: topAnchor, constant: 3.0),
            walletAddressLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3.0),
            walletAddressLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7.0),
            
            copyImageView.leadingAnchor.constraint(equalTo: walletAddressLabel.trailingAnchor, constant: 10.0),
            copyImageView.centerYAnchor.constraint(equalTo: walletAddressLabel.centerYAnchor),
            copyImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8.0)
        ])
    }
    
    func configure(walletAddress: String) {
        walletAddressLabel.text = walletAddress
    }

    override func sendActions(for controlEvents: UIControl.Event) {
        switch(controlEvents) {
        case .touchUpInside:
            delegate?.walletAddressCustomViewDelegateDidTapCopyButton()
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate protocol WalletAddressCustomViewDelegate: AnyObject {
    func walletAddressCustomViewDelegateDidTapCopyButton()
}
