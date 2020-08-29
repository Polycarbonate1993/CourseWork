//
//  SupplementaryView.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 21.04.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import MastodonKit
import Kingfisher

class SupplementaryView: UICollectionReusableView {

    // MARK: - Outlets and properties
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var note: UITextView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var postsOrMediaSegmentedControl: UISegmentedControl!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var filler: UIImageView!
    var user: Account!
    weak var myDelegate: HeaderDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        filler.backgroundColor = UIColor(white: 0.2, alpha: 0.6)
        followers.layer.cornerRadius = followers.layer.bounds.height / 2
        followers.layer.borderWidth = 2
        followers.layer.borderColor = UIColor(named: "label")?.cgColor
        following.layer.cornerRadius = following.layer.bounds.height / 2
        following.layer.borderWidth = 2
        following.layer.borderColor = UIColor(named: "label")?.cgColor
        avatar.layer.cornerRadius = avatar.layer.bounds.width / 2
//        avatar.layer.masksToBounds = true
        followers.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toTableView)))
        following.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toTableView)))
        followButton.isHidden = true
        mainView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        mainView.layer.cornerRadius = mainView.bounds.size.width / 10
    }
    
    func fill() {
        guard let user = user else {
            return
        }
        if user.id != NewAPIHandler.currentUserID {
            let request = Accounts.relationships(ids: [user.id])
            NewAPIHandler.client.run(request, completion: {result in
                switch result {
                case .success(let relationship, _):
                    if relationship[0].following {
                        self.followButton.setImage(UIImage(named: "person.badge.minus.fill"), for: .normal)
                        self.followButton.tintColor = UIColor(named: "liked")
                    } else {
                        self.followButton.setImage(UIImage(named: "person.badge.plus.fill"), for: .normal)
                        self.followButton.tintColor = UIColor(named: "unliked")
                    }
                case .failure(let error):
                    print("error: \(error.asOAuth2Error.description)")
                }
            })
        }
        headerImage.kf.setImage(with: ImageResource(downloadURL: URL(string: user.header)!, cacheKey: user.header))
        avatar.kf.setImage(with: ImageResource(downloadURL: URL(string: user.avatar)!, cacheKey: user.avatar))
        username.text = "@\(user.username)"
        let attributedText = try? NSMutableAttributedString(data: user.note.data(using: .utf8)!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        if attributedText!.string != "" {
            attributedText?.deleteCharacters(in: NSRange.init(location: attributedText!.length - 1, length: 1))
            note.attributedText = attributedText
            note.font = UIFont.init(name: "Helvetica-Bold", size: 14)
            note.textColor = UIColor(named: "profileInfo")
        } else {
            note.attributedText = nil
        }
        fullName.text = user.displayName
        followers.text = "Followers: \(user.followersCount)"
        following.text = "Following: \(user.followingCount)"
    }

    // MARK: - Actions handling
    
    @objc func toTableView(sender: UIGestureRecognizer) {
//        if sender.view == followers{
//            myDelegate?.toTable(userId: user.id, title: "Followers")
//        } else if sender.view == following {
//            myDelegate?.toTable(userId: user.id, title: "Following")
//        }
    }
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
//        if currentUserFollowing == false {
//            (myDelegate as? ProfileViewController)?.apiHandler.get(.follow, withID: user.id, completionHandler: {user in
//                guard let newUser = user as? User else {
//                    (self.myDelegate as? UIViewController)?.generateAlert(title: "Oops!", message: "Something with decoding JSON.", buttonTitle: "OK")
//                    return
//                }
//                self.user = newUser
//                DispatchQueue.main.async {
//                    self.followers.text = "Followers: \(self.user!.followedByCount!)"
//                    self.currentUserFollowing = true
//                }
//            })
//        } else {
//            (myDelegate as? ProfileViewController)?.apiHandler.get(.unfollow, withID: user.id, completionHandler: {user in
//                guard let newUser = user as? User else {
//                    (self.myDelegate as? UIViewController)?.generateAlert(title: "Oops!", message: "Something with decoding JSON.", buttonTitle: "OK")
//                    return
//                }
//                self.user = newUser
//                DispatchQueue.main.async {
//                    self.followers.text = "Followers: \(self.user!.followedByCount!)"
//                    self.currentUserFollowing = false
//                }
//            })
//        }
    }
}

    // MARK: - HeaderDelegate protocol declaration

protocol HeaderDelegate: class {
    func toTable(userId: String, title: String) -> Void
}
