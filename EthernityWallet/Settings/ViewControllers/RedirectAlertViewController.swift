//
//  RedirectAlertViewController.swift
//  EthernityWallet
//
//  Created by Bogdan Velesca on 25.05.2022.
//

import UIKit

protocol RedirectAlertViewControllerDelegate: AnyObject {
    func redirectAlertViewController(redirectAlertViewController: RedirectAlertViewController, didTapCancelButton cancelButton: UIButton)
    func redirectAlertViewController(redirectAlertViewController: RedirectAlertViewController, didTapAllowButton allowButton: UIButton, forServiceProvider serviceProvider: URLServiceProvider)
}

class RedirectAlertViewController: UIViewController {
    // outlets
    private var titleLabel = UILabel()
    private var appNameLabel = UILabel()
    private var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: ScreenChecker().isNarrowScreen ? 32 : 40),
            button.widthAnchor.constraint(equalToConstant: ScreenChecker().isNarrowScreen ? 80 : 90)
        ])
        return button
        
    }()
    private var allowButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleEdgeInsets.left = 16
        button.titleEdgeInsets.right = 16
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: ScreenChecker().isNarrowScreen ? 32 : 40),
            button.widthAnchor.constraint(equalToConstant: ScreenChecker().isNarrowScreen ? 80 : 90)
        ])
        return button
        
    }()
    private let viewModel: RedirectAlertViewModel
    private var containerView = UIView()
    weak var delegate: RedirectAlertViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    init(viewModel: RedirectAlertViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        allowButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(appNameLabel)

        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 18
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.distribution = .equalSpacing
        stackView.addArrangedSubviews([cancelButton, allowButton])
        
        containerView.addSubview(stackView)
        
        containerView.layer.cornerRadius = 12
        containerView.backgroundColor = Colors.appWhite
        
        titleLabel.numberOfLines = 0
        
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: ScreenChecker().isNarrowScreen ? 24: 32),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: ScreenChecker().isNarrowScreen ? -24: -32),
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            
            appNameLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 48),
            appNameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: appNameLabel.topAnchor, constant: 48),
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -32),
        ])
        
        configureBlurView()
        
        setupUI()
    }
    
    private func setupUI() {
        titleLabel.attributedText = viewModel.titleString
        appNameLabel.attributedText = viewModel.appNameAttributedString
        
        cancelButton.setAttributedTitle(viewModel.cancelString, for: .normal)
        cancelButton.cornerRadius = viewModel.cancelButtonCornerRadius
        cancelButton.backgroundColor = viewModel.cancelButtonBackgroundColor
        cancelButton.borderWidth = viewModel.cancelButtonBorderWidth
        cancelButton.borderColor = viewModel.cancelButtonBorderColor
        cancelButton.addTarget(self, action: #selector(cancelPressed(sender:)), for: .touchUpInside)
        
        
        allowButton.setAttributedTitle(viewModel.allowString, for: .normal)
        allowButton.cornerRadius = viewModel.allowButtonCornerRadius
        allowButton.backgroundColor = viewModel.allowButtonBackgroundColor
        allowButton.addTarget(self, action: #selector(allowPressed(sender:)), for: .touchUpInside)
        
    }
    
    private func configureBlurView() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        self.view.insertSubview(blurView, at: 0)
        
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
        ])
        
        let gestureRecognizer = UITapGestureRecognizer(target: self,action: #selector(cancelPressed(sender:)))
        blurView.addGestureRecognizer(gestureRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    @objc func allowPressed(sender: UIButton!) {
        dismiss(animated: true) {
            self.delegate?.redirectAlertViewController(redirectAlertViewController: self, didTapAllowButton: sender, forServiceProvider: self.viewModel.urlServiceProvider)
        }
    }
    
    @objc func cancelPressed(sender: UIButton!) {
        dismiss(animated: true) {
            self.delegate?.redirectAlertViewController(redirectAlertViewController: self, didTapCancelButton: sender)
        }
    }
    
}

