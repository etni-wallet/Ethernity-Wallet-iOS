//
//  AboutViewController.swift
//  EthernityWallet
//
//  Created by Bogdan Velesca on 23.05.2022.
//

import UIKit

class AboutViewController: UIViewController {
    private var viewModel: AboutViewModel
    
    private var walletImgView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.widthAnchor.constraint(equalToConstant: 120.0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 120.0).isActive = true
        
        return imageView
    }()
    private var appNameAndVersionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    private var appDescriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    private var copyrightLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Colors.appBackground
        navigationItem.title = viewModel.navigationTitle
        
        view.addSubview(walletImgView)
        view.addSubview(appNameAndVersionLabel)
        view.addSubview(appDescriptionLabel)
        view.addSubview(copyrightLabel)
        NSLayoutConstraint.activate([
            walletImgView.topAnchor.constraint(equalTo: view.topAnchor, constant: 44),
            walletImgView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            appNameAndVersionLabel.topAnchor.constraint(equalTo: walletImgView.bottomAnchor, constant: 16),
            appNameAndVersionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            appDescriptionLabel.topAnchor.constraint(equalTo: view.centerYAnchor),
            appDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            appDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            appDescriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: copyrightLabel.topAnchor, constant: -16),
            
            copyrightLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            copyrightLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
    }
    
    init() {
        viewModel = AboutViewModel()
        super.init(nibName: nil, bundle: nil)
        configure()
    }
    
    private func configure() {
        walletImgView.image = viewModel.walletIcon
        appNameAndVersionLabel.attributedText = viewModel.appNameAndVersion
        appDescriptionLabel.attributedText = viewModel.appDescription
        copyrightLabel.attributedText = viewModel.copyright
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
}
