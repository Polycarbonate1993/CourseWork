//
//  FeedViewController.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 20.04.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData

class FeedViewController: UIViewController, UICollectionViewDataSource {
    
    // MARK: - Outlets and properties
    
    @IBOutlet weak var feed: UICollectionView!
    @IBAction func unwind(unwindSegue: UIStoryboardSegue) {}
    let apiHandler = APIHandler()
    var feedData: [Post] = []
    
    
    // MARK: - View configuration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiHandler.delegate = self
        if feedData.isEmpty {
            getFeed()
        }
        
        feed.dataSource = self
        feed.delegate = self
        feed.register(UINib(nibName: "FeedCell", bundle: nil), forCellWithReuseIdentifier: "FeedSample")
    }
    
    func getFeed() {
        apiHandler.get(.feed, withID: nil, completionHandler: {feedData in
            guard let data = feedData as? [Post] else {
                return
            }
            self.feedData = data
            if APIHandler.offlineMode == false {
                self.saveFeedToDataBase()
            }
            print(self.feedData.count)
            DispatchQueue.main.async {
                self.feed.reloadData()
            }
        })
    }
    
    private func saveFeedToDataBase() {
        var fetchedPosts = (self.tabBarController as! TabBarController).dataManager.fetchData(for: CoreDataPost.self, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "inFeed == TRUE")]))
        if !fetchedPosts.isEmpty {
            for post in fetchedPosts {
                (self.tabBarController as! TabBarController).dataManager.delete(object: post)
            }
        }
        let context = (tabBarController as! TabBarController).dataManager.getContext()
        let newArray: [CoreDataPost] = feedData.exportToCoreDataFromDecodedJSONData(withMarker: true, CoreDataPost.self)
        (tabBarController as! TabBarController).dataManager.save(context: context)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedData.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedSample", for: indexPath) as! FeedCell
        let post = feedData[indexPath.item]
        cell.post = feedData[indexPath.item]
        
        cell.date.text = post.dateFormattingFromJSON()
        cell.descriptionLabel.text = post.description
        cell.likes.text = "Likes: \(post.likedByCount!)"
        cell.username.text = post.authorUsername
        if APIHandler.offlineMode {
            cell.mainImage.image = UIImage(data: Data(base64Encoded: post.image)!)
            cell.avatar.image = UIImage(data: Data(base64Encoded: post.authorAvatar)!)
        } else {
            cell.mainImage.kf.setImage(with: ImageResource(downloadURL: URL(string: post.image)!, cacheKey: post.image))
            cell.avatar.kf.setImage(with: ImageResource(downloadURL: URL(string: post.authorAvatar)!, cacheKey: post.authorAvatar))
        }
        cell.delegate = self
        return cell
    }
    
    
}

extension FeedViewController: UICollectionViewDelegate {}

    // MARK: - UICollectionViewDelegateFlowLayout

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 8 + 35 + 8 + 44 + 55
        height += feed.frame.width
        return CGSize(width: feed.frame.width, height: height)
    }
}

    // MARK: - FeedCellDelegate

extension FeedViewController: FeedCellDelegate {

    func toAuthorProfile(withID id: String) {
        if id == APIHandler.currentUserId {
            self.performSegue(withIdentifier: "unwindToProfile", sender: self)
        } else {
            self.performSegue(withIdentifier: "unwindToProfile", sender: self)
            apiHandler.get(.user, withID: id, completionHandler: {user in
                guard let user = user as? User else {
                    self.generateAlert(title: "Oops!", message: "Something with decoding JSON.", buttonTitle: "OK")
                    return
                }
                DispatchQueue.main.async {
                    let newVC = self.storyboard?.instantiateViewController(identifier: "Profile") as! ProfileViewController
                    newVC.usernameTitle.title = user.username
                    (self.tabBarController?.viewControllers?[2] as! UINavigationController).popToRootViewController(animated: false)
                    (self.tabBarController?.viewControllers?[2] as! UINavigationController).pushViewController(newVC, animated: true)
                    newVC.user = user
                }
            })
        }
    }

    func toLikes(ofPostID id: String) {
        apiHandler.get(.likes, withID: id, completionHandler: {users in
            guard let likingUsers = users as? [User] else {
                self.generateAlert(title: "Oops!", message: "Something with decoding JSON.", buttonTitle: "OK")
                return
            }
            DispatchQueue.main.async {
                let newVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableController") as! UsersTableViewController
                newVC.navigationItem.title = "Likes"
                newVC.data = likingUsers
                let backButtonTitle = self.navigationItem.title
                self.navigationController?.pushViewController(newVC, animated: true)
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
                self.navigationItem.backBarButtonItem?.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17)], for: .normal)
                self.navigationItem.backBarButtonItem?.tintColor = .systemBlue
            }
        })
    }
}
    
   
