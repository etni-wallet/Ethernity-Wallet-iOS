//
//  AccountWalletsPageView.swift
//  EthernityWallet
//
//  Created by Emanuel Baba on 25.05.2022.
//

import UIKit
import Combine

// simple example view controller
// has a label 90% of the width, centered X and Y
class ExampleViewController: UIViewController {

    let theLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.textAlignment = .center
        return v
    }()
    
    let cardView :UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.blue
        
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(theLabel)
        NSLayoutConstraint.activate([
            theLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            theLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            theLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            ])

    }

}

// example Page View Controller
class MyPageViewController: UIPageViewController {

    let colors: [UIColor] = [
        .red,
        .green,
        .blue,
        .cyan,
        .yellow,
        .orange
    ]

    var pages: [UIViewController] = [UIViewController]()

    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = nil

        // instantiate "pages"
        for i in 0..<colors.count {
            let vc = ExampleViewController()
            vc.theLabel.text = "Asamutzat: \(i)"
            vc.view.backgroundColor = UIColor.clear
            pages.append(vc)
        }

        setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
    }
    

}

// typical Page View Controller Data Source
extension MyPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else { return pages.last }

        guard pages.count > previousIndex else { return nil }

        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }

        let nextIndex = viewControllerIndex + 1

        guard nextIndex < pages.count else { return pages.first }

        guard pages.count > nextIndex else { return nil }

        return pages[nextIndex]
    }
}

// typical Page View Controller Delegate
extension MyPageViewController: UIPageViewControllerDelegate {

    // if you do NOT want the built-in PageControl (the "dots"), comment-out these funcs

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {

        guard let firstVC = pageViewController.viewControllers?.first else {
            return 0
        }
        guard let firstVCIndex = pages.index(of: firstVC) else {
            return 0
        }

        return firstVCIndex
    }
}

class MyTestViewController: UIViewController {

    let myContainerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .gray
        return v
    }()

    var thePageVC: MyPageViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // add myContainerView
        view.addSubview(myContainerView)

        // constrain it - here I am setting it to
        //  40-pts top, leading and trailing
        //  and 200-pts height
        NSLayoutConstraint.activate([
            myContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40.0),
            myContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40.0),
            myContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40.0),
            myContainerView.heightAnchor.constraint(equalToConstant: 200.0),
            ])

        // instantiate MyPageViewController and add it as a Child View Controller
        thePageVC = MyPageViewController()
        addChild(thePageVC)

        // we need to re-size the page view controller's view to fit our container view
        thePageVC.view.translatesAutoresizingMaskIntoConstraints = false

        // add the page VC's view to our container view
        myContainerView.addSubview(thePageVC.view)

        // constrain it to all 4 sides
        NSLayoutConstraint.activate([
            thePageVC.view.topAnchor.constraint(equalTo: myContainerView.topAnchor, constant: 0.0),
            thePageVC.view.bottomAnchor.constraint(equalTo: myContainerView.bottomAnchor, constant: 0.0),
            thePageVC.view.leadingAnchor.constraint(equalTo: myContainerView.leadingAnchor, constant: 0.0),
            thePageVC.view.trailingAnchor.constraint(equalTo: myContainerView.trailingAnchor, constant: 0.0),
            ])

        thePageVC.didMove(toParent: self)
    }

}
