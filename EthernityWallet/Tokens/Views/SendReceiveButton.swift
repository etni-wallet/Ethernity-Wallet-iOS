//
//  SendReceiveButton.swift
//  EthernityWallet
//
//  Created by Bogdan Velesca on 02.06.2022.
//

import UIKit

enum SendReceiveButtonType: Int, CaseIterable {
    case send
    case receive
    
    var icon: UIImage {
        switch(self) {
        case .send:
            return R.image.sendIcon()!
        case .receive:
            return R.image.receiveIcon()!
        }
    }
    
    var title: String {
        switch(self) {
        case .send:
            return R.string.localizable.walletsFlowSendButtonTitle()
        case .receive:
            return R.string.localizable.walletsFlowReceiveButtonTitle()
        }
    }
}

class SendReceiveButton: UIControl {
    private var background: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6.0
        view.backgroundColor = EthernityColors.electricYellow
        
        return view
    }()
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        
        return label
    }()
    private var iconImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.translatesAutoresizingMaskIntoConstraints = false
        
        return imgView
    }()
    private let type: SendReceiveButtonType
    weak var delegate: SendReceiveButtonDelegate?

    init(type: SendReceiveButtonType) {
        self.type = type
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        addSubview(background)
        
        background.addSubview(titleLabel)
        background.addSubview(iconImgView)
        
        NSLayoutConstraint.activate([
            background.anchorsConstraint(to: self),
            
            titleLabel.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 25.0),
            titleLabel.topAnchor.constraint(equalTo: background.topAnchor, constant: 11.0),
            titleLabel.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -11.0),
            
            iconImgView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            iconImgView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10.0),
            iconImgView.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -10.0)
        ])
        
    }
    
    override func sendActions(for controlEvents: UIControl.Event) {
        switch(controlEvents) {
        case .touchUpInside:
            delegate?.sendReceiveButtonTapped(type: type)
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol SendReceiveButtonDelegate: AnyObject {
    func sendReceiveButtonTapped(type: SendReceiveButtonType)
}
