// Copyright © 2018 Stormbird PTE. LTD.
import Foundation
import UIKit
import CoreImage
import MBProgressHUD

//Careful to fit in shorter phone like iPhone 5s without needing to scroll
class RequestViewController: UIViewController {
	private let roundedBackground: RoundedBackground = {
		let roundedBackground = RoundedBackground()
		roundedBackground.translatesAutoresizingMaskIntoConstraints = false
		return roundedBackground
	}()

	private let scrollView = UIScrollView()
	private let copyEnsButton = UIButton(type: .system)
	private let copyAddressButton = UIButton(type: .system)
    private let copyAddressButtonBar = HorizontalButtonsBar(configuration: .primary(buttons: 1))
    private let shareAdressButtonBar = HorizontalButtonsBar(configuration: .whiteBackgroundYellowText(buttons: 1))
	private lazy var instructionLabel: UILabel = {
		let label = UILabel()
		label.textColor = viewModel.labelColor
		label.font = viewModel.instructionFont
		label.adjustsFontSizeToFitWidth = true
		label.text = viewModel.instructionText
		return label
	}()

	private lazy var imageView: UIImageView = {
		let imageView = UIImageView()
        imageView.borderWidth = 12
        imageView.layer.cornerRadius = 12
        imageView.borderColor = EthernityColors.electricBlueLight
		return imageView
	}()

	private lazy var addressContainerView: UIView = {
		let v = UIView()
		v.backgroundColor = viewModel.addressBackgroundColor
        v.isUserInteractionEnabled = true

		return v
	}()

	private lazy var addressLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = viewModel.addressLabelColor
		label.font = viewModel.addressFont
		label.text = viewModel.myAddressText
		label.textAlignment = .center
		label.numberOfLines = 0

		return label
	}()

	private lazy var ensContainerView: UIView = {
		let v = UIView()
		v.backgroundColor = viewModel.addressBackgroundColor
        v.isHidden = true
        v.isUserInteractionEnabled = true

		return v
	}()

	private lazy var ensLabel: UILabel = {
		let label = UILabel(frame: .zero)
		label.textColor = viewModel.addressLabelColor
		label.font = viewModel.addressFont
		label.textAlignment = .center
		label.minimumScaleFactor = 0.5
		label.adjustsFontSizeToFitWidth = true

		return label
	}()

	private let viewModel: RequestViewModel

	init(viewModel: RequestViewModel) {
		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)

        title = R.string.localizable.aSettingsContentsMyWalletAddress()

		view.backgroundColor = viewModel.backgroundColor
		view.addSubview(roundedBackground)

        ensContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyEns)))
        addressContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyAddress)))

		copyEnsButton.addTarget(self, action: #selector(copyEns), for: .touchUpInside)
        copyEnsButton.setContentHuggingPriority(.required, for: .horizontal)

		let ensStackView = [.spacerWidth(7), ensLabel, .spacerWidth(10), copyEnsButton, .spacerWidth(7)].asStackView(axis: .horizontal)
		ensStackView.addSubview(forBackgroundColor: viewModel.addressBackgroundColor)
		ensStackView.translatesAutoresizingMaskIntoConstraints = false
		ensContainerView.addSubview(ensStackView)

		copyAddressButton.addTarget(self, action: #selector(copyAddress), for: .touchUpInside)
		copyAddressButton.setContentHuggingPriority(.required, for: .horizontal)

        copyAddressButtonBar.translatesAutoresizingMaskIntoConstraints = false
        copyAddressButtonBar.configure()
        let copyAddressEthernityButton = copyAddressButtonBar.buttons[0]
        copyAddressEthernityButton.setTitle("Copy Wallet Address", for: .normal)
        copyAddressEthernityButton.addTarget(self, action: #selector(copyAddress), for: .touchUpInside)
        
        shareAdressButtonBar.translatesAutoresizingMaskIntoConstraints = false
        shareAdressButtonBar.configure()
        let shareAdressButton = shareAdressButtonBar.buttons[0]
        shareAdressButton.setTitle("Share with Others", for: .normal)
        shareAdressButton.addTarget(self, action: #selector(shareWallet), for: .touchUpInside)
        shareAdressButton.borderWidth = 2
        shareAdressButton.borderColor = EthernityColors.electricYellow
        
        
		let addressStackView = [addressLabel].asStackView(axis: .horizontal)
		addressStackView.addSubview(forBackgroundColor: viewModel.addressBackgroundColor)
		addressStackView.translatesAutoresizingMaskIntoConstraints = false
		addressContainerView.addSubview(addressStackView)

		scrollView.translatesAutoresizingMaskIntoConstraints = false
		roundedBackground.addSubview(scrollView)

		let stackView = [
			.spacer(height: ScreenChecker().isNarrowScreen ? 20 : 50),
			imageView,
		].asStackView(axis: .vertical, alignment: .center)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(stackView)

		ensContainerView.translatesAutoresizingMaskIntoConstraints = false
		roundedBackground.addSubview(ensContainerView)

        addressStackView.translatesAutoresizingMaskIntoConstraints = false
		roundedBackground.addSubview(addressStackView)

        roundedBackground.addSubview(copyAddressButtonBar)
        roundedBackground.addSubview(shareAdressButtonBar)
		let qrCodeDimensions: CGFloat
		if ScreenChecker().isNarrowScreen {
			qrCodeDimensions = 230
		} else {
			qrCodeDimensions = 260
		}
		NSLayoutConstraint.activate([
			//Leading/trailing anchor needed to make label fit when on narrow iPhones
			ensStackView.anchorsConstraint(to: ensContainerView, edgeInsets: .init(top: 14, left: 20, bottom: 14, right: 20)),
			addressStackView.anchorsConstraint(to: addressStackView, edgeInsets: .init(top: 14, left: 20, bottom: 14, right: 20)),

			imageView.widthAnchor.constraint(equalToConstant: qrCodeDimensions),
			imageView.heightAnchor.constraint(equalToConstant: qrCodeDimensions),

			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
			stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
			stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.topAnchor.constraint(equalTo: view.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            copyAddressButton.widthAnchor.constraint(equalToConstant: 30),

            ensContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			ensContainerView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 0),

            addressStackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: ScreenChecker().isNarrowScreen ? 10 : 20),
            addressStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addressStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            copyAddressButtonBar.heightAnchor.constraint(equalToConstant: HorizontalButtonsBar.buttonsHeight),
            copyAddressButtonBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            copyAddressButtonBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            copyAddressButtonBar.bottomAnchor.constraint(equalTo: shareAdressButtonBar.topAnchor, constant: -16),
            
            shareAdressButtonBar.heightAnchor.constraint(equalToConstant: HorizontalButtonsBar.buttonsHeight),
            shareAdressButtonBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -60),
            shareAdressButtonBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            shareAdressButtonBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            shareAdressButtonBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            
			roundedBackground.createConstraintsWithContainer(view: view),
		])

		changeQRCode(value: 0)

		configure()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		addressContainerView.cornerRadius = addressContainerView.frame.size.height / 2
		ensContainerView.cornerRadius = ensContainerView.frame.size.height / 2
	}

	private func configure() {
		copyEnsButton.setImage(R.image.copy(), for: .normal)
		copyAddressButton.setImage(R.image.copy(), for: .normal)

		resolveEns()
	}

	private func resolveEns() {
		let address = viewModel.myAddress
        let resolver: DomainResolutionServiceType = DomainResolutionService()
        resolver.resolveEns(address: address).done { [weak self] result in
            guard let strongSelf = self else { return }

            if let ensName = result.resolution.value {
                strongSelf.ensLabel.text = ensName
                strongSelf.ensContainerView.isHidden = false
                strongSelf.ensContainerView.cornerRadius = strongSelf.ensContainerView.frame.size.height / 2
            } else {
                strongSelf.ensLabel.text = nil
                strongSelf.ensContainerView.isHidden = true
            }
        }.catch { [weak self] _ in
            guard let strongSelf = self else { return }

            strongSelf.ensLabel.text = nil
            strongSelf.ensContainerView.isHidden = true
        }
	}

	@objc func textFieldDidChange(_ textField: UITextField) {
		changeQRCode(value: Int(textField.text ?? "0") ?? 0)
	}

	func changeQRCode(value: Int) {
		let string = viewModel.myAddressText

		// EIP67 format not being used much yet, use hex value for now
		// let string = "ethereum:\(account.address.address)?value=\(value)"

		DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
			let image = strongSelf.generateQRCode(from: string)
			DispatchQueue.main.async {
				strongSelf.imageView.image = image
			}
		}
	}
    
    @objc private func shareWallet() {
        let text = viewModel.myAddressText
        let textShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

	@objc func copyAddress() {
		UIPasteboard.general.string = viewModel.myAddressText

		let hud = MBProgressHUD.showAdded(to: view, animated: true)
		hud.mode = .text
		hud.label.text = viewModel.addressCopiedText
		hud.hide(animated: true, afterDelay: 1.5)

		showFeedback()
	}

	@objc func copyEns() {
		UIPasteboard.general.string = ensLabel.text ?? ""

		let hud = MBProgressHUD.showAdded(to: view, animated: true)
		hud.mode = .text
		hud.label.text = viewModel.addressCopiedText
		hud.hide(animated: true, afterDelay: 1.5)

		showFeedback()
	}

	private func showFeedback() {
		UINotificationFeedbackGenerator.show(feedbackType: .success)
	}

	func generateQRCode(from string: String) -> UIImage? {
		return string.toQRCode()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

fileprivate extension UIStackView {
	func addSubview(forBackgroundColor backgroundColor: UIColor) {
		let v = UIView(frame: bounds)
		v.backgroundColor = backgroundColor
		v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		insertSubview(v, at: 0)
	}
}
