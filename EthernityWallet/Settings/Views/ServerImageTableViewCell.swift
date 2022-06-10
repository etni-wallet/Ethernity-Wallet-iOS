//
//  ServerImageTableViewCell.swift
//  AlphaWallet
//
//  Created by Jerome Chan on 18/4/22.
//

import UIKit

class ServerImageTableViewCell: UITableViewCell {

    // MARK: - Properties

    // MARK: Private
    private let chainIconView: ImageView = ImageView()
    private let accessoryImageView: UIImageView = UIImageView()
    private let infoView: ServerInformationView = ServerInformationView()
    private let topSeparator: UIView = UIView.separator(backgroundColor: UIColor(hex: "F0F0F0"))

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        constructView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Configuration and Construction

    // MARK: Public

    func configure(viewModel: ServerImageTableViewCellViewModelType) {
        configureView(viewModel: viewModel)
        //configureChainIconView(viewModel: viewModel)
        configureInfoView(viewModel: viewModel)
        configureAccessoryImageView(viewModel: viewModel)
    }

    // MARK: Private

    private func constructView() {
        topSeparator.translatesAutoresizingMaskIntoConstraints = false
        chainIconView.translatesAutoresizingMaskIntoConstraints = false
        infoView.translatesAutoresizingMaskIntoConstraints = false
        accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topSeparator)
        //addSubview(chainIconView)
        addSubview(infoView)
        addSubview(accessoryImageView)
        NSLayoutConstraint.activate([
            topSeparator.topAnchor.constraint(equalTo: contentView.topAnchor),
            topSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            topSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -60),

//            chainIconView.widthAnchor.constraint(equalToConstant: 40.0),
//            chainIconView.heightAnchor.constraint(equalToConstant: 40.0),
//            chainIconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
//            chainIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
//            chainIconView.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: topAnchor, multiplier: 1.0),
//            chainIconView.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: bottomAnchor, multiplier: 1.0),

            infoView.leadingAnchor.constraint(equalTo: leadingAnchor/*chainIconView.trailingAnchor*/, constant: 30.0),
            infoView.trailingAnchor.constraint(equalTo: accessoryImageView.leadingAnchor),
            infoView.centerYAnchor.constraint(equalTo: centerYAnchor),
            infoView.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: topAnchor, multiplier: 1.0),
            infoView.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: bottomAnchor, multiplier: 1.0),

            accessoryImageView.widthAnchor.constraint(equalToConstant: 20.0),
            accessoryImageView.heightAnchor.constraint(equalToConstant: 15.0),
            accessoryImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0),
            accessoryImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            accessoryImageView.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: topAnchor, multiplier: 1.0),
            accessoryImageView.bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: bottomAnchor, multiplier: 1.0),
        ])
    }

    private func configureView(viewModel: ServerImageTableViewCellViewModelType) {
        selectionStyle = viewModel.selectionStyle
        backgroundColor = viewModel.backgroundColor
        topSeparator.isHidden = viewModel.isTopSeparatorHidden
    }

    private func configureChainIconView(viewModel: ServerImageTableViewCellViewModelType) {
        let imageSubscription = RPCServerImageFetcher.instance.image(server: viewModel.server)
        chainIconView.subscribable = imageSubscription
    }

    private func configureInfoView(viewModel: ServerImageTableViewCellViewModelType) {
        infoView.configure(viewModel: viewModel)
    }

    private func configureAccessoryImageView(viewModel: ServerImageTableViewCellViewModelType) {
        let image = viewModel.isSelected ? R.image.iconsSystemCheckboxOn() : R.image.iconsSystemCheckboxOff()!.withTintColor(.white)
        accessoryImageView.image = image
    }
    
}

// MARK: - private class

private class ServerInformationView: UIView {

    // MARK: - Properties

    // MARK: Private
    private let primaryTextLabel: UILabel = UILabel()
    private let secondaryTextLabel: UILabel = UILabel()

    // MARK: - Initializers

    init() {
        super.init(frame: .zero)
        constructView()
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    // MARK: - Configuration and Construction

    // MARK: Public

    func configure(viewModel: ServerImageTableViewCellViewModelType) {
        primaryTextLabel.font = viewModel.primaryFont
        primaryTextLabel.text = viewModel.primaryText
        primaryTextLabel.textColor = viewModel.primaryFontColor
        secondaryTextLabel.isHidden = viewModel.isSecondLabelHidden
        if !viewModel.isSecondLabelHidden {
            secondaryTextLabel.font = viewModel.secondaryFont
            secondaryTextLabel.text = viewModel.secondaryText
            secondaryTextLabel.textColor = viewModel.secondaryFontColor
        }
        
    }

    // MARK: Private
    
    private func constructView() {
        primaryTextLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryTextLabel.translatesAutoresizingMaskIntoConstraints = false
        primaryTextLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        secondaryTextLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        addSubview(primaryTextLabel)
        addSubview(secondaryTextLabel)
        NSLayoutConstraint.activate([
            primaryTextLabel.topAnchor.constraint(equalTo: topAnchor),
            primaryTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            primaryTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            primaryTextLabel.bottomAnchor.constraint(equalTo: secondaryTextLabel.topAnchor),
            secondaryTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            secondaryTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            secondaryTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
