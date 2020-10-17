//
//  NavigationController.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 23.04.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let backItem = UIBarButtonItem(customView: <#T##UIView#>)
    }

    // MARK: - Changing default behavior
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let popped = super.popViewController(animated: animated)
        navigationController(self, didShow: self.visibleViewController! , animated: animated)
        return popped
    }

    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let popped = super.popToRootViewController(animated: animated)
        navigationController(self, didShow: self.visibleViewController!, animated: animated)
        return popped
    }

}

    // MARK: - UINavigationControllerDelegate

extension NavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
    }
}
