//
//  EducationViewController.swift
//  EthernityWallet
//
//  Created by Florin Velesca on 23.05.2022.
//
import Foundation
import UIKit

class EducationViewController: UIViewController {
    private let viewModel: EducationViewModel
    private let scrollView = UIScrollView()
    private let coordinator: EducationCoordinator


    private lazy var safetyTipLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = Fonts.regular(size: 15)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.text = "Remember to backup your wallet, if your device gets lost or stolen you will lose all your funds, unless you made a backup"
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = .max
        return label
    }()

    private lazy var safetyTipTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = EthernityColors.electricBlueLight
        label.font = Fonts.semibold(size: 18)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.minimumScaleFactor = 0.5
        label.text = "Safety tip"
        return label
    }()

    private lazy var begginerGuideTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = EthernityColors.electricBlueLight
        label.font = Fonts.semibold(size: 18)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.minimumScaleFactor = 0.5
        label.text = "Beginner’s Guide"
        return label
    }()

    private lazy var roundedBlueCelllfirst: RoundedBlueCell = {
        let roundedCell = RoundedBlueCell(model: RoundedBlueCellModel(type: .square))
        roundedCell.assignbackground(type: RoundedBlueCellType.square)
        roundedCell.translatesAutoresizingMaskIntoConstraints = false
        return roundedCell
    }()

    private lazy var roundedBlueCelllsecond: RoundedBlueCell = {
        let roundedCell = RoundedBlueCell(model: RoundedBlueCellModel(type: .honey))
        roundedCell.assignbackground(type: RoundedBlueCellType.honey)
        roundedCell.translatesAutoresizingMaskIntoConstraints = false
        return roundedCell
    }()

    private lazy var verticalLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 3)
        ])
        view.backgroundColor = .orange

        return view

    }()

    init(viewModel: EducationViewModel, navigationController: UINavigationController) {
        self.viewModel = viewModel
        self.coordinator = EducationCoordinator(navigationController: navigationController)
        super.init(nibName: nil, bundle: nil)
        navigationItem.largeTitleDisplayMode = .always
    }

    //View Controller life cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func configure() {
        title = "Education"
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .always
        let safetyTipStackView = [
            verticalLine,
            .spacerWidth(12),
            safetyTipLabel
        ].asStackView(axis: .horizontal)
        safetyTipStackView.distribution = .fillProportionally

        let tipStackView = [
            safetyTipTitleLabel,
            .spacer(height: 6),
            safetyTipStackView,
            .spacer(height: 40),
            begginerGuideTitleLabel,
            .spacer(height: 12),
            roundedBlueCelllfirst,
            .spacer(height: 36),
            roundedBlueCelllsecond
        ].asStackView(axis: .vertical)
        tipStackView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.addSubview(tipStackView)
        view.addSubview(tipStackView)
        NSLayoutConstraint.activate([
            tipStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            tipStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            tipStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
        ])
        let firstClickGesture = UITapGestureRecognizer(target: self, action:  #selector(self.didTapFirstCell))
        roundedBlueCelllfirst.addGestureRecognizer(firstClickGesture)
        let secondClickGesture = UITapGestureRecognizer(target: self, action:  #selector(self.didTapSecondCell))
        roundedBlueCelllsecond.addGestureRecognizer(secondClickGesture)
    }

    @objc private func didTapFirstCell() {
        coordinator.goToEducationDeatils(with: EducationGuideModel(title: "", date: "", time: ""))
    }

    @objc private func didTapSecondCell() {
        coordinator.goToEducationDeatils(with: EducationGuideModel(title: "", date: "", time: ""))
    }
}
