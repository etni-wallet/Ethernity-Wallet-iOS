//
//  WalletTokenViewCell.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 07.06.2021.
//

import UIKit

class WalletTokenViewCell: UITableViewCell {
    private let background = UIView()
    private let titleLabel = UILabel()
    private let cryptoValueLabel = UILabel()
    private var viewsWithContent: [UIView] {
        [titleLabel, cryptoValueLabel]
    }

    private var tokenIconImageView: TokenImageView = {
        let imageView = TokenImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private var blockChainTagLabel = BlockchainTagLabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.layer.cornerRadius = 12
        contentView.addSubview(background)
        background.translatesAutoresizingMaskIntoConstraints = false
        background.cornerRadius = 12
        let stackView = [
            tokenIconImageView,
            [cryptoValueLabel, titleLabel, UIView.spacerWidth(flexible: true)].asStackView(spacing: 5)
        ].asStackView(spacing: 12, alignment: .center)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        background.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            tokenIconImageView.heightAnchor.constraint(equalToConstant: 35),
            tokenIconImageView.widthAnchor.constraint(equalToConstant: 35),
            stackView.anchorsConstraint(to: background, edgeInsets: .init(top: 8, left: 30, bottom: 8, right: 16)),
            background.anchorsConstraint(to: contentView)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    func configure(viewModel: WalletTokenViewCellViewModel) {
        selectionStyle = .none

        backgroundColor = viewModel.isVisible ? .clear : viewModel.contentsBackgroundColor
        background.backgroundColor = viewModel.contentsBackgroundColor
        contentView.backgroundColor = UIColor(hex: "F4F4F4")

        titleLabel.attributedText = viewModel.titleAttributedString
        titleLabel.baselineAdjustment = .alignCenters

        cryptoValueLabel.attributedText = viewModel.cryptoValueAttributedString

        viewsWithContent.forEach {
            $0.alpha = viewModel.alpha
        }
        
        tokenIconImageView.subscribable = viewModel.iconImage

        blockChainTagLabel.configure(viewModel: viewModel.blockChainTagViewModel)
    }
    
    override func layoutSubviews() {
         super.layoutSubviews()
         contentView.bounds = CGRect(origin: CGPoint(x: self.bounds.origin.x, y: self.bounds.origin.y), size: CGSize(width: (0.91 * self.bounds.size.width), height: self.bounds.size.height))

         contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0))
    }
}
