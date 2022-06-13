//
//  RoundedBlueCell.swift
//  EthernityWallet
//
//  Created by Florin Velesca on 23.05.2022.
//
import Foundation
import UIKit

class RoundedBlueCell: UIView {

    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semibold(size: 16)
        label.textColor = .white
        label.text = "How to stake your ETNY tokens"
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.semibold(size: 12)
        label.textColor = .white
        label.text = "February 19, \u{2022} 2020 5mins read"
        return label
    }()

    var model = RoundedBlueCellModel(type: .square)

    init(model: RoundedBlueCellModel) {
        super.init(frame: .zero)
        self.model = model
        configure()
    }


    func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        cornerRadius = 6
        backgroundColor = UIColor(patternImage: model.type.backgroundImage)
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        let stackView = [instructionLabel,
                         .spacer(height: 5),
                         dateLabel].asStackView(axis: .vertical, alignment: .leading)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        NSLayoutConstraint.activate([ stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
                                      stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
                                      stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -50),
                                      self.heightAnchor.constraint(equalToConstant: 110)
                                    ])
    }

    func assignbackground(type: RoundedBlueCellType){
        self.model = RoundedBlueCellModel(type: type)
        backgroundColor = UIColor(patternImage: model.type.backgroundImage)
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    func createConstraintsWithContainer(view: UIView) -> [NSLayoutConstraint] {
        return view.anchorsConstraint(to: self)
    }
}
