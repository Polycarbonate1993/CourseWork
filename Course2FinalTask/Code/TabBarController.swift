//
//  TabBarController.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 25.05.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import MastodonKit

class TabBarController: UITabBarController {
    var mastodonApiHandler: NewAPIHandler?
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        tabBar.layer.cornerRadius = UIScreen.main.bounds.width / 10
    }
}
