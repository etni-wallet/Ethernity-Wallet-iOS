//
//  CustomUITabController.swift
//  EthernityWallet
//
//  Created by Emanuel Baba on 14.05.2022.
//

import UIKit

class CustomTabController: UITabBarController {

    var previousBarItemView : UIView?
    var indicatorImage: UIImageView?
    private let yOffset : CGFloat = 15
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let barItemView = item.value(forKey: "view") as? UIView else { return }

        let timeInterval: TimeInterval = 0.5
        let selectedPropertyAnimator = UIViewPropertyAnimator(duration: timeInterval, dampingRatio: 0.8) {
            //barItemView.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
            barItemView.frame.origin.y -= yOffset
            self.previousBarItemView?.frame.origin.y += yOffset
        }
        //selectedPropertyAnimator.addAnimations({ barItemView.transform = .identity }, delayFactor: CGFloat(timeInterval))
        selectedPropertyAnimator.startAnimation()

        previousBarItemView = barItemView
        
        UIView.animate(withDuration: 0.3) {
              let number = -(tabBar.items?.index(of: item)?.distance(to: 0))! + 1
              if number == 1 {
                self.indicatorImage?.center.x =  tabBar.frame.width/3/2
              } else if number == 2 {
                self.indicatorImage?.center.x =  tabBar.frame.width/3/2 + tabBar.frame.width/3
              } else {
                self.indicatorImage?.center.x = tabBar.frame.width - tabBar.frame.width/3/2
              }
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let numberOfItems = 3.0
        indicatorImage = UIImageView(image: R.image.tab_wallet_clouds())
        indicatorImage?.center.x = tabBar.frame.width/numberOfItems/2
        tabBar.addSubview(indicatorImage!)
        self.indicatorImage?.center.y -= tabBar.frame.height
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if previousBarItemView == nil {
            guard let tabItem = tabBar.selectedItem else { return }
            guard let tabItemView = tabItem.value(forKey: "view") as? UIView else { return }
            tabItemView.frame.origin.y -= yOffset
            previousBarItemView = tabItemView
        } else {
            previousBarItemView?.frame.origin.y -= yOffset
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tabBar.frame.size.height = ScreenChecker.size(big: 120, medium: 120, small: 85)
        tabBar.frame.origin.y = view.frame.height - ScreenChecker.size(big: 120, medium: 120, small: 85)
    }
}
