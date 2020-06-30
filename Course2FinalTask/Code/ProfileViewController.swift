//
//  ProfileViewController.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 21.04.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import Kingfisher

class ProfileViewController: UIViewController, UICollectionViewDataSource {

    @IBAction func unwind(unwindSegue: UIStoryboardSegue) {}


    @IBOutlet weak var profile: UICollectionView!
    @IBOutlet weak var usernameTitle: UINavigationItem!
    
    let apiHandler = APIHandler()
    
    var user: User? {
        didSet {
            apiHandler.get(.userPosts, withID: user?.id, completionHandler: {userPosts in
                guard let newPosts = userPosts as? [Post] else {
                    self.generateAlert(title: "Oops!", message: "Something with decoding JSON.", buttonTitle: "OK")
                    return
                }
                self.userPosts = newPosts.reversed()
                DispatchQueue.main.async {
                    self.profile?.reloadData()
                }
            })
        }
    }
    var userPosts:[Post] = []

    var indexForRow: IndexPath?



    override func viewDidLoad() {
        super.viewDidLoad()
        apiHandler.delegate = self
        if user == nil {
            apiHandler.get(.user, withID: nil, completionHandler: {fetchedUser in
                guard let newUser = fetchedUser as? User else {
                    self.generateAlert(title: "Oops!", message: "Something with decoding JSON.", buttonTitle: "OK")
                    return
                }
                self.user = newUser
            })
        }
        profile.dataSource = self
        profile.delegate = self

        profile.register(UINib(nibName: "ProfileCell", bundle: nil), forCellWithReuseIdentifier: "ProfileSample")
        profile.register(UINib(nibName: "SupplementaryView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SupplementarySample")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.logOut))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17)], for: .normal)
        self.navigationItem.rightBarButtonItem?.tintColor = .systemBlue


        // Do any additional setup after loading the view.
    }
    
    @objc func logOut() {
        apiHandler.signout(completionHandler: {
            DispatchQueue.main.async {
                let newVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                UIApplication.shared.delegate?.window??.rootViewController = newVC
            }
            
        })
    }

    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return dataProvider.postsDataProvider.findPosts(by: user.id)?.count ?? 0
        return userPosts.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileSample", for: indexPath) as! ProfileCell
        cell.mainImage.kf.setImage(with: ImageResource(downloadURL: URL(string: userPosts[indexPath.item].image)!, cacheKey: userPosts[indexPath.item].image))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SupplementarySample", for: indexPath) as! SupplementaryView
        reusableView.avatar.kf.setImage(with: ImageResource(downloadURL: URL(string: user!.avatar)!, cacheKey: user!.avatar))
        reusableView.fullName.text = user!.fullName
        reusableView.followers.text = "Followers: \(user!.followedByCount!)"
        reusableView.following.text = "Following: \(user!.followsCount!)"
        reusableView.myDelegate = self
        reusableView.user = user
        if user!.id == APIHandler.currentUserId {
            reusableView.followButton.isHidden = true
            return reusableView
        } else if user!.currentUserFollowsThisUser != false {
            reusableView.currentUserFollowing = true
            reusableView.followButton.isHidden = false
            return reusableView
        } else {
            reusableView.currentUserFollowing = false
            reusableView.followButton.isHidden = false
            return reusableView
        }
//        return UICollectionReusableView()

    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension ProfileViewController: UICollectionViewDelegate {}

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3

        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 86)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension ProfileViewController: HeaderDelegate {
    func toTable(userId: String, title: String) {
        let newVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableController") as! UsersTableViewController
        switch title {
        case "Followers":
            newVC.navigationItem.title = title
            apiHandler.get(.followers, withID: userId, completionHandler: {users in
                guard let followers = users as? [User] else {
                    self.generateAlert(title: "Oops!", message: "Something with decoding JSON.", buttonTitle: "OK")
                    return
                }
                DispatchQueue.main.async {
                    newVC.data = followers
                    newVC.hostUser = userId
                    let backButtonTitle = self.navigationItem.title
                    self.navigationController?.pushViewController(newVC, animated: true)

                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
                    self.navigationItem.backBarButtonItem?.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17)], for: .normal)
                    self.navigationItem.backBarButtonItem?.tintColor = .systemBlue
                }
                
            })
            
        case "Following":
            newVC.navigationItem.title = title
            apiHandler.get(.following, withID: userId, completionHandler: {users in
                guard let followers = users as? [User] else {
                    self.generateAlert(title: "Oops!", message: "Something with decoding JSON.", buttonTitle: "OK")
                    return
                }
                DispatchQueue.main.async {
                    newVC.data = followers
                    newVC.hostUser = userId
                    let backButtonTitle = self.navigationItem.title
                    self.navigationController?.pushViewController(newVC, animated: true)

                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
                    self.navigationItem.backBarButtonItem?.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17)], for: .normal)
                    self.navigationItem.backBarButtonItem?.tintColor = .systemBlue
                }
            })
        default:
            print("SMTH WRONG! ! ! !")
            newVC.navigationItem.title = title
            newVC.data = []
            let backButtonTitle = self.navigationItem.title
            self.navigationController?.pushViewController(newVC, animated: true)

            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
            self.navigationItem.backBarButtonItem?.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17)], for: .normal)
            self.navigationItem.backBarButtonItem?.tintColor = .systemBlue
        }


    }



}
