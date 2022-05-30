//
//  ButtonsPageViewController.swift
//  EthernityWallet
//
//  Created by Emanuel Baba on 29.05.2022.
//

import Foundation
import UIKit

protocol ButtonsPageViewControllerDelegate: AnyObject {
    func createWalletPressed(in viewController: UIViewController)
    func importWalletPressed(in viewController: UIViewController)
    func showCopyWalletPressed(in viewController: UIViewController)
    func showSeedPhrasePressed(in viewController: UIViewController)
    func renameWalletPressed(in viewController: UIViewController)
    func removeWalletPressed(in viewController: UIViewController)
}

class ButtonsPageViewController : UIViewController {
    
    // define lazy views
    let vTopLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "8D8D92")
        view.layer.cornerRadius = 4
        view.layer.maskedCorners = CACornerMask(rawValue: UIRectCorner.allCorners.rawValue)
        return view
    }()
    
    let createWalletButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create New Wallet", for: .normal)
        button.setImage(R.image.new_wallet_icon(), for: .normal)
        button.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        button.cornerRadius = 12
        button.borderWidth = 2
        button.setTitleColor(UIColor(hex: "6D6D6D"), for: .normal)
        button.titleLabel?.font = R.font.interRegular(size: 14)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    let importWalletButton: UIButton = {
        let button = UIButton()
        button.setTitle("Import Wallet", for: .normal)
        button.setImage(R.image.import_wallet_icon(), for: .normal)
        button.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        button.cornerRadius = 12
        button.borderWidth = 2
        button.setTitleColor(UIColor(hex: "6D6D6D"), for: .normal)
        button.titleLabel?.font = R.font.interRegular(size: 14)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    let showCopyWalletButton: UIButton = {
        let button = UIButton()
        button.setTitle("Show/Copy\nWallet Address", for: .normal)
        button.setImage(R.image.show_copy_wallet_icon(), for: .normal)
        button.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        button.cornerRadius = 12
        button.borderWidth = 2
        button.setTitleColor(UIColor(hex: "6D6D6D"), for: .normal)
        button.titleLabel?.font = R.font.interRegular(size: 14)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 2
        return button
    }()
    
    let showSeedPhraseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Show My\nSeed Phrase", for: .normal)
        button.setImage(R.image.show_seed_phrase_icon(), for: .normal)
        button.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        button.cornerRadius = 12
        button.borderWidth = 2
        button.setTitleColor(UIColor(hex: "6D6D6D"), for: .normal)
        button.titleLabel?.font = R.font.interRegular(size: 14)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 2
        return button
    }()
    
    let renameWalletButton: UIButton = {
        let button = UIButton()
        button.setTitle("Rename Wallet", for: .normal)
        button.setImage(R.image.rename_wallet_icon(), for: .normal)
        button.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        button.cornerRadius = 12
        button.borderWidth = 2
        button.setTitleColor(UIColor(hex: "6D6D6D"), for: .normal)
        button.titleLabel?.font = R.font.interRegular(size: 14)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    let removeWalletButton: UIButton = {
        let button = UIButton()
        button.setTitle("Remove Wallet", for: .normal)
        button.setImage(R.image.show_seed_phrase_icon(), for: .normal)
        button.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        button.cornerRadius = 12
        button.borderWidth = 2
        button.setTitleColor(UIColor(hex: "6D6D6D"), for: .normal)
        button.titleLabel?.font = R.font.interRegular(size: 14)
        button.titleLabel?.textAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var newWalletStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [createWalletButton, importWalletButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 30.0
        return stackView
    }()
    
    lazy var showInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [showCopyWalletButton, showSeedPhraseButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 30.0
        return stackView
    }()
    
    lazy var modifyWalletStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [renameWalletButton, removeWalletButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 30.0
        return stackView
    }()
    
    lazy var contentStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [vTopLine, .spacer(height: 5), newWalletStackView, showInfoStackView, modifyWalletStackView, spacer])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 15.0
        return stackView
    }()
       
    lazy var containerView: UIView = {
           let view = UIView()
           view.backgroundColor = .white
           view.layer.cornerRadius = 16
           view.clipsToBounds = true
           return view
       }()
       
    let maxDimmedAlpha: CGFloat = 0.75
    lazy var dimmedView: UIView = {
           let view = UIView()
           view.backgroundColor = UIColor(red: 109, green: 109, blue: 109)
           view.alpha = maxDimmedAlpha
           return view
       }()
       
    var defaultHeight: CGFloat = 400
    var dismissibleHeight: CGFloat = 200
    var maximumContainerHeight: CGFloat = 400//UIScreen.main.bounds.height - 64
    // keep current new height, initial is default height
    var currentContainerHeight: CGFloat = 400
       
    // Dynamic container constraint
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    weak var delegate: ButtonsPageViewControllerDelegate?
    
    init(createPopUp: Bool) {
        super.init(nibName: nil, bundle: nil)
        configureView(createPopUP: createPopUp)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        adjustImageAndTitleOffsetsForButton(button: createWalletButton)
        adjustImageAndTitleOffsetsForButton(button: importWalletButton)
        adjustImageAndTitleOffsetsForButton(button: showCopyWalletButton)
        adjustImageAndTitleOffsetsForButton(button: showSeedPhraseButton)
        adjustImageAndTitleOffsetsForButton(button: renameWalletButton)
        adjustImageAndTitleOffsetsForButton(button: removeWalletButton)
        // tap gesture on dimmed view to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
        
        createWalletButton.addTarget(self, action: #selector(createWalletButtonPressed), for: .touchUpInside)
        importWalletButton.addTarget(self, action: #selector(importWalletButtonPressed), for: .touchUpInside)
        showCopyWalletButton.addTarget(self, action: #selector(showCopyWalletButtonPressed), for: .touchUpInside)
        showSeedPhraseButton.addTarget(self, action: #selector(showSeedPhraseButtonPressed), for: .touchUpInside)
        renameWalletButton.addTarget(self, action: #selector(renameWalletButtonPressed), for: .touchUpInside)
        removeWalletButton.addTarget(self, action: #selector(removeWalletButtonPressed), for: .touchUpInside)
        
        setupPanGesture()
    }
       
    @objc func handleCloseAction() {
        animateDismissView()
    }
       
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
        animatePresentContainer()
    }
       
    func setupView() {
        view.backgroundColor = .clear
    }
       
    func setupConstraints() {
        // Add subviews
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
           
        containerView.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
           
        // Set static constraints
        NSLayoutConstraint.activate([
            vTopLine.heightAnchor.constraint(equalToConstant: 8),
            vTopLine.widthAnchor.constraint(equalToConstant: 64),
            createWalletButton.heightAnchor.constraint(equalToConstant: 130),
            createWalletButton.widthAnchor.constraint(equalToConstant: 150),
            importWalletButton.heightAnchor.constraint(equalToConstant: 130),
            importWalletButton.widthAnchor.constraint(equalToConstant: 150),
            showCopyWalletButton.heightAnchor.constraint(equalToConstant: 130),
            showCopyWalletButton.widthAnchor.constraint(equalToConstant: 150),
            showSeedPhraseButton.heightAnchor.constraint(equalToConstant: 130),
            showSeedPhraseButton.widthAnchor.constraint(equalToConstant: 150),
            renameWalletButton.heightAnchor.constraint(equalToConstant: 130),
            renameWalletButton.widthAnchor.constraint(equalToConstant: 150),
            removeWalletButton.heightAnchor.constraint(equalToConstant: 130),
            removeWalletButton.widthAnchor.constraint(equalToConstant: 150),
            // set dimmedView edges to superview
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // set container static constraint (trailing & leading)
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // content stackView
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 17),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
        ])
           
           // Set dynamic constraints
           // First, set container to default height
           // after panning, the height can expand
           containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
           
           // By setting the height to default height, the container will be hide below the bottom anchor view
           // Later, will bring it up by set it to 0
           // set the constant to default height to bring it down again
           containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
           // Activate constraints
           containerViewHeightConstraint?.isActive = true
           containerViewBottomConstraint?.isActive = true
       }
       
       func setupPanGesture() {
           // add pan gesture recognizer to the view controller's view (the whole screen)
           let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
           // change to false to immediately listen on gesture movement
           panGesture.delaysTouchesBegan = false
           panGesture.delaysTouchesEnded = false
           view.addGestureRecognizer(panGesture)
       }
       
       // MARK: Pan gesture handler
       @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
           let translation = gesture.translation(in: view)
           // Drag to top will be minus value and vice versa
           print("Pan gesture y offset: \(translation.y)")
           
           // Get drag direction
           let isDraggingDown = translation.y > 0
           print("Dragging direction: \(isDraggingDown ? "going down" : "going up")")
           
           // New height is based on value of dragging plus current container height
           let newHeight = currentContainerHeight - translation.y
           
           // Handle based on gesture state
           switch gesture.state {
           case .changed:
               // This state will occur when user is dragging
               if newHeight < maximumContainerHeight {
                   // Keep updating the height constraint
                   containerViewHeightConstraint?.constant = newHeight
                   //self.containerViewBottomConstraint?.constant = (currentContainerHeight - newHeight) > 13 ? (currentContainerHeight - newHeight) : 13
                   // refresh layout
                   view.layoutIfNeeded()
               }
           case .ended:
               // This happens when user stop drag,
               // so we will get the last height of container
               
               // Condition 1: If new height is below min, dismiss controller
               if newHeight < dismissibleHeight {
                   self.animateDismissView()
               }
               else if newHeight < defaultHeight {
                   // Condition 2: If new height is below default, animate back to default
                   animateContainerHeight(defaultHeight)
               }
               else if newHeight < maximumContainerHeight && isDraggingDown {
                   // Condition 3: If new height is below max and going down, set to default height
                   animateContainerHeight(defaultHeight)
               }
               else if newHeight > defaultHeight && !isDraggingDown {
                   // Condition 4: If new height is below max and going up, set to max height at top
                   animateContainerHeight(maximumContainerHeight)
               }
           default:
               break
           }
       }
       
       func animateContainerHeight(_ height: CGFloat) {
           UIView.animate(withDuration: 0.4) {
               // Update container height
               self.containerViewHeightConstraint?.constant = height
               // Call this to trigger refresh constraint
               self.view.layoutIfNeeded()
           }
           // Save current height
           currentContainerHeight = height
       }
       
       // MARK: Present and dismiss animation
       func animatePresentContainer() {
           // update bottom constraint in animation block
           UIView.animate(withDuration: 0.3) {
               self.containerViewBottomConstraint?.constant = 13
               // call this to trigger refresh constraint
               self.view.layoutIfNeeded()
           }
       }
       
       func animateShowDimmedView() {
           dimmedView.alpha = 0
           UIView.animate(withDuration: 0.4) {
               self.dimmedView.alpha = self.maxDimmedAlpha
           }
       }
       
       func animateDismissView() {
           // hide blur view
           dimmedView.alpha = maxDimmedAlpha
           UIView.animate(withDuration: 0.4) {
               self.dimmedView.alpha = 0
           } completion: { _ in
               // once done, dismiss without animation
               self.dismiss(animated: false)
           }
           // hide main view by updating bottom constraint in animation block
           UIView.animate(withDuration: 0.3) {
               self.containerViewBottomConstraint?.constant = self.defaultHeight
               // call this to trigger refresh constraint
               self.view.layoutIfNeeded()
           }
       }
    
    private func adjustImageAndTitleOffsetsForButton (button: UIButton) {

       let spacing: CGFloat = 20.0

       let imageSize = button.imageView!.frame.size

        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0)

       let titleSize = button.titleLabel!.frame.size

        button.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0, bottom: 0, right: -titleSize.width)
   }
    
    private func configureView(createPopUP: Bool) {
        if createPopUP {
            newWalletStackView.isHidden = false
            showInfoStackView.isHidden = true
            modifyWalletStackView.isHidden = true
            defaultHeight = 250
            maximumContainerHeight = 250
            currentContainerHeight = 250
        }
        else
        {
            newWalletStackView.isHidden = true
            showInfoStackView.isHidden = false
            modifyWalletStackView.isHidden = false
            defaultHeight = 390
            maximumContainerHeight = 390
            currentContainerHeight = 390
        }
    }
    
    @objc func createWalletButtonPressed() {
        delegate?.createWalletPressed(in: self)
    }
    
    @objc func importWalletButtonPressed() {
        delegate?.importWalletPressed(in: self)
    }
    
    @objc func showSeedPhraseButtonPressed() {
        delegate?.showSeedPhrasePressed(in: self)
    }
    
    @objc func showCopyWalletButtonPressed() {
        delegate?.showCopyWalletPressed(in: self)
    }
    
    @objc func renameWalletButtonPressed() {
        delegate?.renameWalletPressed(in: self)
    }
    
    @objc func removeWalletButtonPressed() {
        delegate?.removeWalletPressed(in: self)
    }
}
