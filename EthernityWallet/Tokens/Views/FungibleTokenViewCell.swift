// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import UIKit
import Kingfisher

class FungibleTokenViewCell: UITableViewCell {
    private let background = UIView()
    private let titleLabel = UILabel()
    private let apprecation24hoursView = ApprecationView()
    private let priceChangeLabel = UILabel()
    private let fiatValueLabel = UILabel()
    private let cryptoValueLabel = UILabel()
    private var viewsWithContent: [UIView] {
        [titleLabel, apprecation24hoursView, priceChangeLabel]
    }

    private lazy var changeValueContainer: UIView = [/*priceChangeLabel,*/ apprecation24hoursView].asStackView(spacing: 0/*5*/)

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
        priceChangeLabel.textAlignment = .center
        fiatValueLabel.textAlignment = .center
        cryptoValueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        cryptoValueLabel.setContentHuggingPriority(.required, for: .horizontal)

        let col0 = tokenIconImageView
        let row1 = [changeValueContainer, UIView.spacerWidth(flexible: true), fiatValueLabel/*, blockChainTagLabel*/].asStackView(spacing: 5, alignment: .center)
        let col1 = [
            [titleLabel, UIView.spacerWidth(flexible: true), cryptoValueLabel].asStackView(spacing: 5),
            row1
        ].asStackView(axis: .vertical)
        let stackView = [col0, col1].asStackView(spacing: 12, alignment: .center)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        background.addSubview(stackView)

        NSLayoutConstraint.activate([
            tokenIconImageView.heightAnchor.constraint(equalToConstant: 40),
            tokenIconImageView.widthAnchor.constraint(equalToConstant: 40),
            row1.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            stackView.anchorsConstraint(to: background, edgeInsets: .init(top: 12, left: 20, bottom: 16, right: 12)),
            background.anchorsConstraint(to: contentView)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    func configure(viewModel: FungibleTokenViewCellViewModel) {
        selectionStyle = .none

        backgroundColor = UIColor.clear
        background.backgroundColor = viewModel.contentsBackgroundColor
        contentView.backgroundColor = GroupedTable.Color.background

        titleLabel.attributedText = viewModel.titleAttributedString
        titleLabel.baselineAdjustment = .alignCenters

        cryptoValueLabel.attributedText = viewModel.cryptoValueAttributedString
        cryptoValueLabel.baselineAdjustment = .alignCenters

        apprecation24hoursView.configure(viewModel: viewModel.apprecationViewModel)

        priceChangeLabel.attributedText = viewModel.priceChangeUSDValueAttributedString

        fiatValueLabel.attributedText = viewModel.fiatValueAttributedString

        viewsWithContent.forEach {
            $0.alpha = viewModel.alpha
        }
        tokenIconImageView.subscribable = viewModel.iconImage

        //blockChainTagLabel.configure(viewModel: viewModel.blockChainTagViewModel)
        changeValueContainer.isHidden = !viewModel.blockChainTagViewModel.blockChainNameLabelHidden
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.bounds = CGRect(origin: CGPoint(x: self.bounds.origin.x, y: self.bounds.origin.y), size: CGSize(width: (0.91 * self.bounds.size.width), height: self.bounds.size.height))
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
        priceChangeLabel.layer.cornerRadius = 2.0
    }
}
