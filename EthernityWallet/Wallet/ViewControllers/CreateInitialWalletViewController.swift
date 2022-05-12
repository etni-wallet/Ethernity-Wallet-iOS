// Copyright © 2019 Stormbird PTE. LTD.

import UIKit

protocol CreateInitialWalletViewControllerDelegate: AnyObject {
    func didTapCreateWallet(inViewController viewController: CreateInitialWalletViewController)
    func didTapWatchWallet(inViewController viewController: CreateInitialWalletViewController)
    func didTapImportWallet(inViewController viewController: CreateInitialWalletViewController)
}

class CreateInitialWalletViewController: UIViewController {
    private let keystore: Keystore
    private var viewModel = CreateInitialViewModel()
    private let analyticsCoordinator: AnalyticsCoordinator
    private let subtitleLabel = UILabel()
    private let imageView = UIImageView()
    private let cloudTopImgView = UIImageView()
    private let cloudDownImgView = UIImageView()
    private let createWalletButtonBar = HorizontalButtonsBar(configuration: .whiteBackgroundYellowText(buttons: 1))
    private let separator = UIView.spacer(height: 1)
    private let haveWalletLabel = UILabel()
    private let buttonsBar = HorizontalButtonsBar(configuration: .primary(buttons: 1))


    weak var delegate: CreateInitialWalletViewControllerDelegate?

    init(keystore: Keystore, analyticsCoordinator: AnalyticsCoordinator) {
        self.keystore = keystore
        self.analyticsCoordinator = analyticsCoordinator
        super.init(nibName: nil, bundle: nil)

        imageView.contentMode = .scaleAspectFit
        cloudTopImgView.contentMode = .scaleAspectFit
        cloudDownImgView.contentMode = .scaleAspectFit

        view.addSubview(imageView)
        view.addSubview(cloudTopImgView)
        view.addSubview(cloudDownImgView)
        view.addSubview(subtitleLabel)
        view.addSubview(buttonsBar)
        view.addSubview(createWalletButtonBar)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        cloudTopImgView.translatesAutoresizingMaskIntoConstraints = false
        cloudDownImgView.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        createWalletButtonBar.translatesAutoresizingMaskIntoConstraints = false
        buttonsBar.translatesAutoresizingMaskIntoConstraints = false

//        let footerBar = UIView()
//        footerBar.translatesAutoresizingMaskIntoConstraints = false
//        footerBar.backgroundColor = .clear
//        roundedBackground.addSubview(footerBar)

//        footerBar.addSubview(buttonsBar)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            cloudTopImgView.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: -60),
            cloudTopImgView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cloudDownImgView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 60),
            cloudDownImgView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            createWalletButtonBar.heightAnchor.constraint(equalToConstant: HorizontalButtonsBar.buttonsHeight),
            createWalletButtonBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
            createWalletButtonBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createWalletButtonBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createWalletButtonBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            buttonsBar.heightAnchor.constraint(equalToConstant: HorizontalButtonsBar.buttonsHeight),
            buttonsBar.bottomAnchor.constraint(equalTo: createWalletButtonBar.topAnchor, constant: -16),
            buttonsBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewDidDisappear(animated)
    }

    func configure() {
        view.backgroundColor = EthernityColors.electricBlueLight

        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = viewModel.subtitleColor
        subtitleLabel.font = viewModel.subtitleFont
        subtitleLabel.text = viewModel.subtitle

        imageView.image = viewModel.imageViewImage
        cloudTopImgView.image = viewModel.cloudTopImage
        cloudDownImgView.image = viewModel.cloudDownImage

        separator.backgroundColor = viewModel.separatorColor

        haveWalletLabel.textAlignment = .center
        haveWalletLabel.textColor = viewModel.alreadyHaveWalletTextColor
        haveWalletLabel.font = viewModel.alreadyHaveWalletTextFont
        haveWalletLabel.text = viewModel.alreadyHaveWalletText

        createWalletButtonBar.configure()
        let createWalletButton = createWalletButtonBar.buttons[0]
        createWalletButton.setTitle(viewModel.createButtonTitle, for: .normal)
        createWalletButton.addTarget(self, action: #selector(createWallet), for: .touchUpInside)
        buttonsBar.configure()
        let watchButton = buttonsBar.buttons[0]
        watchButton.setTitle(viewModel.importButtonTitle, for: .normal)
        watchButton.addTarget(self, action: #selector(importWallet), for: .touchUpInside)
//        let importButton = buttonsBar.buttons[1]
//        importButton.setTitle(viewModel.importButtonTitle, for: .normal)
//        importButton.addTarget(self, action: #selector(importWallet), for: .touchUpInside)
    }

    @objc private func createWallet() {
        delegate?.didTapCreateWallet(inViewController: self)
    }

    @objc private func watchWallet() {
        delegate?.didTapWatchWallet(inViewController: self)
    }

    @objc private func importWallet() {
        delegate?.didTapImportWallet(inViewController: self)
    }
}
