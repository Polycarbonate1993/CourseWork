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
    @IBOutlet weak var backButtonItem: UINavigationItem!
    let newAPIHandler = NewAPIHandler()
    let dispatchGroup = DispatchGroup()
    var feedData: [MutableStatus] = []
    
    
    // MARK: - View configuration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newAPIHandler.delegate = self
        feed.dataSource = self
        
        feed.register(UINib(nibName: "FeedCell", bundle: nil), forCellWithReuseIdentifier: "FeedSample")
        feed.register(UINib(nibName: "FeedCellWithoutContent", bundle: nil), forCellWithReuseIdentifier: "FeedCellWithoutContent")
        if let layout = feed.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
            layout.mode = .tableView
        }
        feed.backgroundColor = .clear
        if UITraitCollection.current.userInterfaceStyle == .dark {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "nightcopy.png")!)
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "daycopy.png")!)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.isNavigationBarHidden = true
        feed.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        newAPIHandler.getFeed(completionHandler: {result in
            guard let result = result else {
                return
            }
            self.feedData = []
            result.forEach({self.feedData.append(MutableStatus($0))})
            self.dispatchGroup.enter()
            result.forEach({item in
                if !item.mediaAttachments.isEmpty {
                    self.dispatchGroup.enter()
                    KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: URL(string: item.mediaAttachments[0].previewURL)!, cacheKey: item.mediaAttachments[0].previewURL), completionHandler: {_ in
                        self.dispatchGroup.leave()
                    })
                }
            })
            self.dispatchGroup.notify(queue: DispatchQueue.main, execute: {
                self.feed.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
//                self.feed.collectionViewLayout.prepare()
//                self.feed.collectionViewLayout.invalidateLayout()
                self.feed.reloadData()
                
                DispatchQueue.global().async {
                    Darwin.sleep(1)
                    DispatchQueue.main.async {
                        self.feed.collectionViewLayout.prepare()
                        self.feed.collectionViewLayout.invalidateLayout()
                    }
                }
                print("okey dokey")
                self.feed.isHidden = false
            })
            self.dispatchGroup.leave()
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.isNavigationBarHidden = false
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
        print("indexPath: \(indexPath.item), feedData item: \(feedData.endIndex)")
        if indexPath.item == feedData.endIndex - 1 {
            getNextPosts(feedData[indexPath.item].id)
        }
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
    
    func getNextPosts(_ id: String) {
        newAPIHandler.getFeed(range: .max(id: id, limit: 10), completionHandler: {statuses in
            guard var statuses = statuses else {
                return
            }
            print("started")
            statuses.removeFirst()
            statuses.forEach({self.feedData.append(MutableStatus($0))})
            statuses.forEach({item in
                if !item.mediaAttachments.isEmpty {
                    self.dispatchGroup.enter()
                    print("item \(item.id)")
                    KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: URL(string: item.mediaAttachments[0].previewURL)!, cacheKey: item.mediaAttachments[0].previewURL), completionHandler: {_ in
                        self.dispatchGroup.leave()
                    })
                }
            })
            self.dispatchGroup.notify(queue: DispatchQueue.main, execute: {
                self.feed.collectionViewLayout.prepare()
                self.feed.reloadData()
                print("got feed")
                self.feed.isHidden = false
            })
        })
    }
    @IBAction func buttonPressed(_ sender: Any) {
        print("feedData count: \(feedData.count)")
//        feed.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        feed.collectionViewLayout.prepare()
//        feed.reloadData()
    }
}

    // MARK: - FeedCellDelegate

extension FeedViewController: FeedCellDelegate {

    func toAuthorProfile(withID id: String) {
        if id == NewAPIHandler.currentUserID {
            self.tabBarController?.selectedIndex = 2
        } else {
            self.newAPIHandler.getUser(withID: id, completionHandler: {user in
                guard let user = user else {
                    return
                }
                DispatchQueue.main.async {
                    let newVC = self.storyboard?.instantiateViewController(identifier: "Profile") as! ProfileViewController
                    newVC.user = MutableAccount(user)
                    self.navigationController?.pushViewController(newVC, animated: true)
                }
            })
        }
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
        DispatchQueue.main.async {
            let newVC = self.storyboard?.instantiateViewController(identifier: "TableController") as! UsersTableViewController
            newVC.retrievingCase = .likes(id)
            self.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
}

extension FeedViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeForPhotoAtIndexPath indexPath: IndexPath) -> CGSize {
        let layout = collectionView.collectionViewLayout as! PinterestLayout
        if feedData[indexPath.item].mediaAttachments.isEmpty {
            let cell = UINib(nibName: "FeedCellWithoutContent", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! FeedCellWithoutContent
            cell.frame.size = CGSize(width: collectionView.frame.width - layout.cellPadding * 2, height: collectionView.frame.height)
            cell.widthAnchor.constraint(equalToConstant: collectionView.frame.width - layout.cellPadding * 2).isActive = true
            cell.post = feedData[indexPath.item]
            cell.fill()
            cell.layoutSubviews()
            return cell.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
        } else {
//            dispatchGroup.enter()
            let cell = UINib(nibName: "FeedCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! FeedCell
            cell.frame.size = CGSize(width: collectionView.frame.width - layout.cellPadding * 2, height: collectionView.frame.height)
            cell.translatesAutoresizingMaskIntoConstraints = false
            cell.widthAnchor.constraint(equalToConstant: collectionView.frame.width - layout.cellPadding * 2).isActive = true
            cell.post = feedData[indexPath.item]
            cell.fill({
//                self.dispatchGroup.leave()
            })
//            dispatchGroup.wait()
            cell.layoutSubviews()
            print(cell.post?.id)
            print("cell size: \(cell.frame.size)")
            print("cell desired size: \(cell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize))")
            let aspectRatio = cell.mainImage.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width / cell.mainImage.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            let height = (collectionView.frame.width) / aspectRatio
            let difference = height - cell.mainImage.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            let cellFinalSize = CGSize(width: collectionView.frame.width, height: cell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + difference)
            print("difference: \(difference)")
            print("final size: \(cellFinalSize)")
            print("current size: \(cell.mainImage.frame.size)")
            print("desired size: \(cell.mainImage.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize))")
            return cellFinalSize
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, kind: String, sizeForTextAtIndexPath indexPath: IndexPath) -> CGSize? {
        nil
    }
    
    
}
    
   
