//
//  RoundedBlueCellModel.swift
//  EthernityWallet
//
//  Created by Florin Velesca on 25.05.2022.
//
import Foundation
import UIKit

struct RoundedBlueCellModel {
    var type: RoundedBlueCellType
}

enum RoundedBlueCellType {
    case square
    case honey

    var backgroundImage: UIImage {
        switch self {
        case .square:
            return R.image.educationCardType1()!
        case .honey:
            return R.image.educationCardType2()!
        }
    }
}
