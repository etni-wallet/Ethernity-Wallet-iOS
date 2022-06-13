//
//  EducationCoordinator.swift
//  EthernityWallet
//
//  Created by Florin Velesca on 25.05.2022.
//
import Foundation
import UIKit

class EducationCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
//    private let config: Config
//    private var keystore: Keystore
//    private let analyticsCoordinator: AnalyticsCoordinator
    var navigationController: UINavigationController

    init(navigationController: UINavigationController){
        self.navigationController = navigationController
        navigationController.navigationBar.isTranslucent = false
    }

    func goToEducationDeatils(with model: EducationGuideModel) {
        let controller = EducationDetailsViewController(viewModel: EducationDetailsViewModel())
        controller.navigationItem.leftBarButtonItem?.image = R.image.ethNavBarBackArrow()?.withRenderingMode(.alwaysOriginal)
        navigationController.pushViewController(controller, animated: false)
    }
}
