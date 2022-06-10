// Copyright © 2019 Stormbird PTE. LTD.

import UIKit

protocol SeedPhraseBackupIntroductionViewControllerDelegate: AnyObject {
    func didTapBackupWallet(inViewController viewController: SeedPhraseBackupIntroductionViewController)
    func didClose(for account: AlphaWallet.Address, inViewController viewController: SeedPhraseBackupIntroductionViewController)
}

class SeedPhraseBackupIntroductionViewController: UIViewController {
    private var viewModel = SeedPhraseBackupIntroductionViewModel()
    private let account: AlphaWallet.Address
    private let roundedBackground = RoundedBackground()
    private let subtitleLabel = UILabel()
    private let imageView = UIImageView()
    // NOTE: internal level, for test cases
    let descriptionLabel1 = UILabel()
    let buttonsBar = HorizontalButtonsBar(configuration: .primary(buttons: 1))

    private var imageViewDimension: CGSize {
        return CGSize(width: 158.0, height: 135.0)
    }
    
    private var imageViewCenterYOffset = ScreenChecker().isNarrowScreen ? -30.0 : -60.0

    weak var delegate: SeedPhraseBackupIntroductionViewControllerDelegate?

    init(account: AlphaWallet.Address) {
        self.account = account
        super.init(nibName: nil, bundle: nil)

        hidesBottomBarWhenPushed = true
        navigationItem.title = viewModel.navBarTitle

        roundedBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(roundedBackground)

        imageView.contentMode = .scaleAspectFit

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel1.translatesAutoresizingMaskIntoConstraints = false
        
        roundedBackground.addSubview(subtitleLabel)
        roundedBackground.addSubview(imageView)
        roundedBackground.addSubview(descriptionLabel1)

        let footerBar = UIView()
        footerBar.translatesAutoresizingMaskIntoConstraints = false
        roundedBackground.backgroundColor = .clear
        roundedBackground.addSubview(footerBar)

        footerBar.addSubview(buttonsBar)

        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40.0),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0),
            
            imageView.heightAnchor.constraint(equalToConstant: imageViewDimension.height),
            imageView.widthAnchor.constraint(equalToConstant: imageViewDimension.width),
            imageView.centerXAnchor.constraint(equalTo: roundedBackground.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: roundedBackground.centerYAnchor, constant: imageViewCenterYOffset),

            
            descriptionLabel1.bottomAnchor.constraint(equalTo: footerBar.topAnchor, constant: -64),
            descriptionLabel1.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 42),
            descriptionLabel1.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -42),

            buttonsBar.leadingAnchor.constraint(equalTo: footerBar.leadingAnchor),
            buttonsBar.trailingAnchor.constraint(equalTo: footerBar.trailingAnchor),
            buttonsBar.bottomAnchor.constraint(equalTo: footerBar.bottomAnchor),
            buttonsBar.heightAnchor.constraint(equalToConstant: HorizontalButtonsBar.buttonsHeight),

            footerBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).set(priority: .defaultHigh),
            footerBar.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -Style.insets.safeBottom - ScreenChecker.size(big: 64, medium: 64, small: 32)).set(priority: .required),
            footerBar.topAnchor.constraint(equalTo: buttonsBar.topAnchor),

        ] + roundedBackground.anchorsConstraint(to: view))
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBarTopSeparatorLine()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showNavigationBarTopSeparatorLine()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            delegate?.didClose(for: account, inViewController: self)
            return
        }
    }

    func configure() {
        view.backgroundColor = Colors.appBackground

        subtitleLabel.numberOfLines = 1
        subtitleLabel.attributedText = viewModel.attributedSubtitle

        imageView.image = viewModel.imageViewImage

        descriptionLabel1.numberOfLines = 0
        descriptionLabel1.attributedText = viewModel.attributedDescription

        buttonsBar.configure()
        let exportButton = buttonsBar.buttons[0]
        exportButton.setTitle(viewModel.title, for: .normal)
        exportButton.addTarget(self, action: #selector(tappedExportButton), for: .touchUpInside)
    }

    @objc private func tappedExportButton() {
        delegate?.didTapBackupWallet(inViewController: self)
    }
}
