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
    @IBOutlet weak var postsOrMediaSegmentedControl: RoundedSegmentedControl!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var filler: UIImageView!
    var newAPIHandler = NewAPIHandler()
    var user: MutableAccount!
    weak var myDelegate: HeaderDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        filler.backgroundColor = UIColor(white: 0.2, alpha: 0.6)
        avatar.layer.cornerRadius = avatar.layer.bounds.width / 2
        avatar.layer.borderWidth = 0.1
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.6
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        followers.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toTableView)))
        followers.textColor = UIColor(named: "followers")
        following.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toTableView)))
        following.textColor = UIColor(named: "followers")
        followButton.isHidden = true
        mainView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
        mainView.layer.cornerRadius = mainView.bounds.size.width / 10
        postsOrMediaSegmentedControl.draw(postsOrMediaSegmentedControl.frame)
    }
    
    @IBAction func followersTapped(_ sender: UIButton) {
        myDelegate?.toTable(userId: user.id, rCase: .followers, sender: sender)
    }
    
    
    @IBAction func followingTapped(_ sender: UIButton) {
        myDelegate?.toTable(userId: user.id, rCase: .following, sender: sender)
    }
    @IBAction func postMediaTapped(_ sender: RoundedSegmentedControl) {
        myDelegate?.segmentedControlPressed(withIndex: sender.selectedIndex)
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
                    if !relationship[0].following {
                        DispatchQueue.main.async {
                            self.followButton.setImage(UIImage(named: "add-user"), for: .normal)
                            self.followButton.tintColor = UIColor(named: "followers")
                            self.followButton.isHidden = false
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.followButton.setImage(UIImage(named: "remove-user"), for: .normal)
                            self.followButton.tintColor = UIColor(named: "liked")
                            self.followButton.isHidden = false
                        }
                    }
                case .failure(let error):
                    print("error: \(error.asOAuth2Error.description)")
                }
            })
        }
        headerImage.kf.setImage(with: ImageResource(downloadURL: URL(string: user.header)!, cacheKey: user.header))
        avatar.kf.setImage(with: ImageResource(downloadURL: URL(string: user.avatar)!, cacheKey: user.avatar))
        username.text = "@\(user.acct)"
        let attributedText = try? NSMutableAttributedString(data: user.note.data(using: .utf8)!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        if attributedText!.string != "" {
            attributedText?.deleteCharacters(in: NSRange.init(location: attributedText!.length - 1, length: 1))
            note.attributedText = attributedText
            note.font = UIFont.init(name: "Helvetica-Bold", size: 14)
            note.textColor = UIColor(named: "profileInfo")
        } else {
            note.attributedText = nil
        }
        fullName.text = user.username
        switch user.followersCount > 9999 {
        case true:
            if user.followersCount > 999999 {
                let decimalPoint = user.followersCount / 100000
                let final = CGFloat(decimalPoint) / 10
                followers.text = "\(final)M"
            } else {
                followers.text = "\(user.followersCount / 1000)K"
            }
        case false:
            followers.text = "\(user.followersCount)"
        }
        switch user.followingCount > 9999 {
        case true:
            if user.followingCount > 999999 {
                let decimalPoint = user.followingCount / 100000
                let final = CGFloat(decimalPoint) / 10
                following.text = "\(final)M"
            } else {
                following.text = "\(user.followingCount / 1000)K"
            }
        case false:
            following.text = "\(user.followingCount)"
        }
    }

    // MARK: - Actions handling
    
    @objc func toTableView(sender: UIGestureRecognizer) {
        if sender.view == followers{
            myDelegate?.toTable(userId: user.id, rCase: .followers, sender: sender.view!)
        } else if sender.view == following {
            myDelegate?.toTable(userId: user.id, rCase: .following, sender: sender.view!)
        }
    }
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
        followButton.isUserInteractionEnabled = false
        let request = Accounts.relationships(ids: [user.id])
        NewAPIHandler.client.run(request, completion: {result in
            switch result {
            case .success(let relationship, _):
                if !relationship[0].following {
                    self.newAPIHandler.follow(id: self.user.id, {account in
                        guard let user = account else {
                            DispatchQueue.main.async {
                                self.followButton.isUserInteractionEnabled = true
                            }
                            return
                        }
                        self.user = MutableAccount(user)
                        print("following")
                        DispatchQueue.main.async {
                            self.followButton.setImage(UIImage(named: "remove-user"), for: .normal)
                            self.followButton.tintColor = UIColor(named: "liked")
                        }
                    })
                    
                } else {
                    self.newAPIHandler.unfollow(id: self.user.id, {account in
                        guard let user = account else {
                            DispatchQueue.main.async {
                                self.followButton.isUserInteractionEnabled = true
                            }
                            return
                        }
                        self.user = MutableAccount(user)
                        print("not following")
                        DispatchQueue.main.async {
                            self.followButton.setImage(UIImage(named: "add-user"), for: .normal)
                            self.followButton.tintColor = UIColor(named: "followers")
                        }
                    })
                    
                }
            case .failure(let error):
                self.followButton.isUserInteractionEnabled = true
                print("error: \(error.asOAuth2Error.description)")
            }
        })
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
    func toTable(userId: String, rCase: UsersTableViewController.RetrievingCase, sender: UIView) -> Void
    func segmentedControlPressed(withIndex index: Int) -> Void 
}
