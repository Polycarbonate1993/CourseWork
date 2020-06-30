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

        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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

extension NavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController is UsersTableViewController {
            (viewController as! UsersTableViewController).usersTable.deselectRow(at: (viewController as! UsersTableViewController).indexForRow!, animated: true)
            if (viewController as! UsersTableViewController).navigationItem.title == "Followers" || (viewController as! UsersTableViewController).navigationItem.title == "Following" {
                (viewController as! UsersTableViewController).renewData()
            }
        } else if viewController is ProfileViewController {
            (viewController as! ProfileViewController).apiHandler.get(.user, completionHandler: {user in
                guard let currentUser = user as? User else {
                    return
                }
                (viewController as! ProfileViewController).user = currentUser
            })
            
        } else if viewController is FeedViewController {
            (viewController as! FeedViewController).getFeed()
        }
    }
}
