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
import MastodonKit

class FeedViewController: UIViewController, UICollectionViewDataSource {
    
    // MARK: - Outlets and properties
    
    @IBOutlet weak var feed: UICollectionView!
    @IBAction func unwind(unwindSegue: UIStoryboardSegue) {}
    let newAPIHandler = NewAPIHandler()
    var feedData: [Status] = []
    
    
    // MARK: - View configuration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newAPIHandler.delegate = self
        feed.dataSource = self
        feed.delegate = self
        feed.register(UINib(nibName: "FeedCell", bundle: nil), forCellWithReuseIdentifier: "FeedSample")
        feed.register(UINib(nibName: "FeedCellWithoutContent", bundle: nil), forCellWithReuseIdentifier: "FeedCellWithoutContent")
        let layout = feed.collectionViewLayout as! UICollectionViewFlowLayout
        layout.estimatedItemSize = CGSize(width: 1, height: 1)
        feed.backgroundColor = .clear
        view.backgroundColor = UIColor(patternImage: UIImage(named: "daycopy.png")!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        feed.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        newAPIHandler.getFeed(completionHandler: {result in
            self.feedData = result
            DispatchQueue.main.async {
                CATransaction.begin()
                CATransaction.setCompletionBlock({
                    print("reload completed")
                    self.feed.scrollToItem(at: IndexPath.init(item: 1, section: 0), at: .top, animated: false)
                    self.feed.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .top, animated: false)
                    self.feed.isHidden = false
                    //Your completion code here
                })
                print("reloading")
                self.feed.reloadData()
                CATransaction.commit()
            }
        })
    }
    
    private func saveFeedToDataBase() {
//        var fetchedPosts = (self.tabBarController as! TabBarController).dataManager.fetchData(for: CoreDataPost.self, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "inFeed == TRUE")]))
//        if !fetchedPosts.isEmpty {
//            for post in fetchedPosts {
//                (self.tabBarController as! TabBarController).dataManager.delete(object: post)
//            }
//        }
//        let context = (tabBarController as! TabBarController).dataManager.getContext()
//        let newArray: [CoreDataPost] = feedData.exportToCoreDataFromDecodedJSONData(withMarker: true, CoreDataPost.self)
//        (tabBarController as! TabBarController).dataManager.save(context: context)
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection != nil {
            if previousTraitCollection!.userInterfaceStyle == .light {
                view.backgroundColor = UIColor(patternImage: UIImage(named: "nightcopy.png")!)
            } else {
                view.backgroundColor = UIColor(patternImage: UIImage(named: "daycopy.png")!)
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if feedData[indexPath.item].mediaAttachments.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCellWithoutContent", for: indexPath) as! FeedCellWithoutContent
            cell.post = feedData[indexPath.item]
            cell.delegate = self
            cell.fill()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedSample", for: indexPath) as! FeedCell
            cell.post = feedData[indexPath.item]
            cell.delegate = self
            cell.fill()
            return cell
        }
    }
}

extension FeedViewController: UICollectionViewDelegate {
}

    // MARK: - UICollectionViewDelegateFlowLayout

//extension FeedViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        var height: CGFloat = 8 + 35 + 8 + 44 + 55
//        height += feed.frame.width
//        return CGSize(width: feed.frame.width, height: height)
//    }
//}

    // MARK: - FeedCellDelegate

extension FeedViewController: FeedCellDelegate {

    func toAuthorProfile(withID id: String) {
//        if id == APIHandler.currentUserId {
//            self.performSegue(withIdentifier: "unwindToProfile", sender: self)
//        } else {
//            self.performSegue(withIdentifier: "unwindToProfile", sender: self)
//            apiHandler.get(.user, withID: id, completionHandler: {user in
//                guard let user = user as? User else {
//                    self.generateAlert(title: "Oops!", message: "Something with decoding JSON.", buttonTitle: "OK")
//                    return
//                }
//                DispatchQueue.main.async {
//                    let newVC = self.storyboard?.instantiateViewController(identifier: "Profile") as! ProfileViewController
//                    newVC.usernameTitle.title = user.username
//                    (self.tabBarController?.viewControllers?[2] as! UINavigationController).popToRootViewController(animated: false)
//                    (self.tabBarController?.viewControllers?[2] as! UINavigationController).pushViewController(newVC, animated: true)
//                    newVC.user = user
//                }
//            })
//        }
    }

    func toLikes(ofPostID id: String) {
//        apiHandler.get(.likes, withID: id, completionHandler: {users in
//            guard let likingUsers = users as? [User] else {
//                self.generateAlert(title: "Oops!", message: "Something with decoding JSON.", buttonTitle: "OK")
//                return
//            }
//            DispatchQueue.main.async {
//                let newVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableController") as! UsersTableViewController
//                newVC.navigationItem.title = "Likes"
//                newVC.data = likingUsers
//                let backButtonTitle = self.navigationItem.title
//                self.navigationController?.pushViewController(newVC, animated: true)
//                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
//                self.navigationItem.backBarButtonItem?.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17)], for: .normal)
//                self.navigationItem.backBarButtonItem?.tintColor = .systemBlue
//            }
//        })
    }
}
    
   
