//
//  EducationDetailsViewController.swift
//  EthernityWallet
//
//  Created by Florin Velesca on 25.05.2022.
//
import Foundation
import UIKit

class EducationDetailsViewController: UIViewController {

    private let viewModel: EducationDetailsViewModel

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = EthernityColors.electricBlueLight
        label.font = Fonts.regular(size: ScreenChecker().isNarrowScreen ? 12 : 15)

        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = EthernityColors.electricBlueLight
        label.font = Fonts.semibold(size: 20)

        return label
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = EthernityColors.electricBlueLight
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = Fonts.regular(size: ScreenChecker().isNarrowScreen ? 11 : 14)

        return label
    }()

    init(viewModel: EducationDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    private func configure() {
        title = viewModel.model.title
        titleLabel.text = viewModel.title
        textLabel.text = viewModel.text
        dateLabel.text = viewModel.model.getTimeAndDate()

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        view?.addSubview(titleLabel)
        view?.addSubview(textLabel)
        view?.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 35),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),

            titleLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)



        ])



    }
}
