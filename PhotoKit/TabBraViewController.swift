//
//  TabBraViewController.swift
//  PhotoKit
//
//  Created by Serhii Kalatur on 02.02.2022.
//

import UIKit

    class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

        override func viewDidLoad() {
            super.viewDidLoad()
            self.delegate = self
            // Do any additional setup after loading the view.
        }
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            let tabOne = DownloadViewController()
            let tabOneBarItem = UITabBarItem(title: "Tab 1", image: UIImage(named: "1"), selectedImage: UIImage(named: "4"))
            tabOne.tabBarItem = tabOneBarItem
            
            
            let tabTwo = ViewController()
            let tabTwoBarItem = UITabBarItem(title: "Tab 2", image: UIImage(named: "4"), selectedImage: UIImage(named: "1"))
            tabTwo.tabBarItem = tabTwoBarItem
            
            self.viewControllers = [tabOne, tabTwo]
        }

        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            print("Selected \(viewController.title)")
        }

}
