//
//  TabBarController.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 25.05.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print(selectedIndex)
        if selectedIndex == 0 && ((viewController as! NavigationController).visibleViewController is FeedViewController){
            ((viewController as! NavigationController).visibleViewController as! FeedViewController).getFeed()
        } else if selectedIndex == 2 && ((viewController as! NavigationController).visibleViewController is ProfileViewController) {
            ((viewController as! NavigationController).visibleViewController as! ProfileViewController).user = ((viewController as! NavigationController).visibleViewController as! ProfileViewController).user
        }
    }
}
