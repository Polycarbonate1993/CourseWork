//
//  SupplementaryView.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 21.04.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

class SupplementaryView: UICollectionReusableView {

    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var following: UILabel!
    var user: User!
    var currentUserFollowing: Bool! {
        didSet {
            if currentUserFollowing {
                followButton.setTitle("Unfollow", for: .normal)

            } else {
                followButton.setTitle("Follow", for: .normal)

            }
        }
    }

    weak var myDelegate: HeaderDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        followButton.layer.cornerRadius = 5

        // Initialization code

//        if followButton.isHidden != true {
//            followButton.sizeToFit()
//        }

        avatar.layer.cornerRadius = avatar.layer.bounds.width / 2
        avatar.layer.masksToBounds = true

        followers.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toTableView)))
        following.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toTableView)))
    }

    @objc func toTableView(sender: UIGestureRecognizer) {
        if sender.view == followers{
            myDelegate?.toTable(userId: user.id, title: "Followers")
        } else if sender.view == following {
            myDelegate?.toTable(userId: user.id, title: "Following")
        }
    }
    @IBAction func followButtonPressed(_ sender: Any) {
        if currentUserFollowing == false {
            (myDelegate as? ProfileViewController)?.apiHandler.get(.follow, withID: user.id, completionHandler: {user in
                guard let newUser = user as? User else {
                    (self.myDelegate as? UIViewController)?.generateAlert(title: "Oops!", message: "Something with decoding JSON.", buttonTitle: "OK")
                    return
                }
                self.user = newUser
                DispatchQueue.main.async {
                    self.followers.text = "Followers: \(self.user!.followedByCount!)"
                    self.currentUserFollowing = true
                }
            })

        } else {
            (myDelegate as? ProfileViewController)?.apiHandler.get(.unfollow, withID: user.id, completionHandler: {user in
                guard let newUser = user as? User else {
                    (self.myDelegate as? UIViewController)?.generateAlert(title: "Oops!", message: "Something with decoding JSON.", buttonTitle: "OK")
                    return
                }
                self.user = newUser
                DispatchQueue.main.async {
                    self.followers.text = "Followers: \(self.user!.followedByCount!)"
                    self.currentUserFollowing = false
                }
            })
        }
    }

}

protocol HeaderDelegate: class {
    func toTable(userId: String, title: String) -> Void
}
