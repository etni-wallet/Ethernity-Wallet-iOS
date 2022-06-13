//
//  EducationDetailsViewModel.swift
//  EthernityWallet
//
//  Created by Florin Velesca on 25.05.2022.
//
import Foundation

class EducationDetailsViewModel {
    var model: EducationGuideModel
    var title: String  = "Introduction"
    var text: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Rhoncus egestas tempus, fermentum at at imperdiet quisque erat. Et lectus nascetur nunc feugiat est egestas enim. Est diam tortor enim, et elementum at elit commodo augue"
    init() {
        self.model = EducationGuideModel(title: "How to become a Node operator", date: "February 19, 2020", time: "5 mins read")
    }
}
