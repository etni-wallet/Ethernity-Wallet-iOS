// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import UIKit
import Kingfisher

class NonFungibleTokenViewCell: UITableViewCell {
    private let background = UIView()
    private let titleLabel = UILabel()
    private let tickersAmountLabel = UILabel()
    private var viewsWithContent: [UIView] {
        [titleLabel, tickersAmountLabel]
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
        tickersAmountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        tickersAmountLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        let col0 = tokenIconImageView
        let col1 = [
            titleLabel, UIView.spacerWidth(flexible: true), tickersAmountLabel].asStackView(spacing: 5)
        let stackView = [col0, col1].asStackView(spacing: 12, alignment: .center)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        background.addSubview(stackView)

        NSLayoutConstraint.activate([
            tokenIconImageView.heightAnchor.constraint(equalToConstant: 40),
            tokenIconImageView.widthAnchor.constraint(equalToConstant: 40),
            stackView.anchorsConstraint(to: background, edgeInsets: .init(top: 16, left: 20, bottom: 16, right: 16)),
            background.anchorsConstraint(to: contentView)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    func configure(viewModel: NonFungibleTokenViewCellViewModel) {
        selectionStyle = .none
        backgroundColor = UIColor.clear

        background.backgroundColor = viewModel.contentsBackgroundColor

        contentView.backgroundColor = GroupedTable.Color.background

        titleLabel.attributedText = viewModel.titleAttributedString
        titleLabel.baselineAdjustment = .alignCenters

        tickersAmountLabel.attributedText = viewModel.tickersAmountAttributedString

        viewsWithContent.forEach {
            $0.alpha = viewModel.alpha
        }
        tokenIconImageView.subscribable = viewModel.iconImage
        blockChainTagLabel.configure(viewModel: viewModel.blockChainTagViewModel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.bounds = CGRect(origin: CGPoint(x: self.bounds.origin.x, y: self.bounds.origin.y), size: CGSize(width: (0.91 * self.bounds.size.width), height: self.bounds.size.height))
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
    }
}
