//
//  EducationViewModel.swift
//  EthernityWallet
//
//  Created by Florin Velesca on 23.05.2022.
//
import Foundation

class EducationViewModel {
    var safetyTipTitle: String {
        return ""
    }

    var guideTitle: String {
        return ""
    }

    var model: EducationGuideModel

    init() {
        self.model = EducationGuideModel(title: "", date: "", time: "")
    }
}
