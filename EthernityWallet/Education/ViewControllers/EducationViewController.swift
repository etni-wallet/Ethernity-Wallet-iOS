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
    
    private lazy var safetyTipLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = Fonts.regular(size: 15)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.layer.addBorder(edge: .left, color: .orange, thickness: 0.5)
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
    
    private lazy var roundedBlueCelll: RoundedBlueCell = {
        let roundedCell = RoundedBlueCell()
        roundedCell.translatesAutoresizingMaskIntoConstraints = false
        return roundedCell
    }()
    
    private lazy var roundedBlueCelll1: RoundedBlueCell = {
        let roundedCell = RoundedBlueCell()
        roundedCell.translatesAutoresizingMaskIntoConstraints = false
        return roundedCell
    }()
    
    init(viewModel: EducationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
//        safetyTipLabel.layer.addBorder(edge: .left, color: .orange, thickness: 0.5)
        let tipStackView = [
            safetyTipTitleLabel,
            .spacer(height: 6),
            safetyTipLabel,
            .spacer(height: 40),
            begginerGuideTitleLabel,
            .spacer(height: 12),
            roundedBlueCelll,
            .spacer(height: 36),
            roundedBlueCelll1
            
        ].asStackView(axis: .vertical)
        tipStackView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.addSubview(tipStackView)
        view.addSubview(tipStackView)
        NSLayoutConstraint.activate([
            tipStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            tipStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            tipStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            roundedBlueCelll.heightAnchor.constraint(equalToConstant: 110),
 
//            tipStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
//            tipStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
//            tipStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 20),
        ])
        
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
        navigationItem.largeTitleDisplayMode = .automatic
    }
}



extension CALayer {

    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {

        let border = CALayer()

        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.height, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: UIScreen.main.bounds.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            break
        }

        border.backgroundColor = color.cgColor;

        self.addSublayer(border)
    }

}
