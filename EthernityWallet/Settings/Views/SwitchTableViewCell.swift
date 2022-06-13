//
//  SwitchTableViewCell.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 01.06.2020.
//

import UIKit

protocol SwitchTableViewCellDelegate: AnyObject {
    func cell(_ cell: SwitchTableViewCell, switchStateChanged isOn: Bool)
}

class SwitchTableViewCell: UITableViewCell {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let switchView: UISwitch = {
        let switchView = UISwitch()
        switchView.onTintColor = R.color.electricBlueSecondary()!
        switchView.translatesAutoresizingMaskIntoConstraints = false
        return switchView
    }()

    var isOn: Bool {
        get { return switchView.isOn }
        set { switchView.isOn = newValue }
    }

    weak var delegate: SwitchTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)

        selectionStyle = .none
        accessoryType = .none

        let stackView = [
            iconImageView, titleLabel, .spacerWidth(flexible: true), switchView
        ].asStackView(axis: .horizontal, spacing: 16, alignment: .center)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.anchorsConstraint(to: contentView, edgeInsets: .init(top: 16, left: 23, bottom: 16, right: 20))
        ])
    }

    @objc private func switchChanged(_ sender: UISwitch) {
        delegate?.cell(self, switchStateChanged: sender.isOn)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: SwitchTableViewCellViewModel) {
        titleLabel.text = viewModel.titleText
        titleLabel.font = viewModel.titleFont
        titleLabel.textColor = viewModel.titleTextColor
        iconImageView.image = viewModel.icon
        switchView.isOn = viewModel.value
    }
}