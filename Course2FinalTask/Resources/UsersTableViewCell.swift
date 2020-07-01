//
//  UsersTableViewCell.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 22.04.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import Kingfisher

class UsersTableViewCell: UITableViewCell {

    var userId: String!
    
    override var safeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        imageView?.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView?.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        imageView?.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        imageView?.widthAnchor.constraint(equalTo: imageView!.heightAnchor).isActive = true
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.leadingAnchor.constraint(equalTo: imageView?.safeAreaLayoutGuide.trailingAnchor ?? safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        textLabel?.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor).isActive = true
        textLabel?.font = UIFont.systemFont(ofSize: 17)
        textLabel?.textColor = .black
    }
}
