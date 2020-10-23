//
//  ProfileViewController.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 21.04.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import Kingfisher
import MastodonKit

class ProfileViewController: UIViewController, UICollectionViewDataSource {

    // MARK: - Outlets and properties
    
    @IBAction func unwind(unwindSegue: UIStoryboardSegue) {}
    @IBOutlet weak var profile: UICollectionView!
    let newAPIHandler = NewAPIHandler()
    let dispatchGroup = DispatchGroup()
    var user: MutableAccount?
    var userPosts: [MutableStatus] = []
    var userMediaPosts: [MutableStatus] = []

    // MARK: - View configuration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController = navigationController, navigationController.topViewController == navigationController.viewControllers[0] {
            let logOutItem = BackItem()
            logOutItem.title = "LOG OUT"
            logOutItem.frame = logOutItem.buttonBounds ?? CGRect(x: 0, y: 0, width: 70, height: 50)
            logOutItem.buttonColor = UIColor(named: "background")
            logOutItem.textColor = UIColor(named: "label")
            logOutItem.isUserInteractionEnabled = true
            logOutItem.addTarget(self, action: #selector(logOut(_:)), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: logOutItem)
            if navigationController.viewControllers.count > 1 {
                let backItem = BackItem()
                backItem.title = "BACK"
                backItem.frame = backItem.buttonBounds ?? CGRect(x: 0, y: 0, width: 50, height: 50)
                backItem.buttonColor = UIColor(named: "background")
                backItem.textColor = UIColor(named: "label")
                backItem.isUserInteractionEnabled = true
                backItem.addTarget(self, action: #selector(backTapped(_:)), for: .touchUpInside)
                navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backItem)
            }
        } else if navigationController != nil {
            let backItem = BackItem()
            backItem.title = "BACK"
            backItem.frame = backItem.buttonBounds ?? CGRect(x: 0, y: 0, width: 50, height: 50)
            backItem.buttonColor = UIColor(named: "background")
            backItem.textColor = UIColor(named: "label")
            backItem.isUserInteractionEnabled = true
            backItem.addTarget(self, action: #selector(backTapped(_:)), for: .touchUpInside)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backItem)
        }
        
        if UITraitCollection.current.userInterfaceStyle == .dark {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "nightcopy.png")!)
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "daycopy.png")!)
        }
        profile.backgroundColor = .clear
        newAPIHandler.delegate = self
        if let layout = profile.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        profile.prefetchDataSource = self
        profile.dataSource = self
        profile.delegate = self
        profile.register(UINib(nibName: "ProfileCell", bundle: nil), forCellWithReuseIdentifier: "ProfileSample")
        profile.register(UINib(nibName: "SupplementaryView", bundle: nil), forSupplementaryViewOfKind: "Header", withReuseIdentifier: "SupplementarySample")
        profile.register(UINib(nibName: "FeedCell", bundle: nil), forCellWithReuseIdentifier: "FeedSample")
        profile.register(UINib(nibName: "FeedCellWithoutContent", bundle: nil), forCellWithReuseIdentifier: "FeedCellWithoutContent")
        
    }
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnSwipe = false
        if user == nil {
            newAPIHandler.getUser(withID: NewAPIHandler.currentUserID ?? "", completionHandler: {result in
                guard let result = result else {
                    return
                }
                self.user = MutableAccount(result)
                
                self.getData()
            })
        } else {
            print("123465")
            getData()
        }
        
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
    
    private func getData() {
        dispatchGroup.enter()
        self.dispatchGroup.notify(queue: DispatchQueue.main, execute: {
            print("321")
//                CATransaction.begin()
//                CATransaction.setCompletionBlock({
//                    (self.profile.collectionViewLayout as! PinterestLayout).reset()
//
//                    self.profile.collectionViewLayout.invalidateLayout()
//                })
            self.profile.reloadData()
//            self.profile.collectionViewLayout.invalidateLayout()
//                CATransaction.commit()
            DispatchQueue.global().async {
                Darwin.sleep(1)
                DispatchQueue.main.async {
                    print("worked")
//                    self.profile.collectionViewLayout.prepare()
                    (self.profile.collectionViewLayout as! PinterestLayout).reset()
                    self.profile.collectionViewLayout.invalidateLayout()
                }
            }
        })
        dispatchGroup.enter()
        newAPIHandler.getUserPosts(withID: user!.id, onlyMedia: false , range: .limit(40), completionHandler: {result in
            guard let result = result else {
                return
            }
            self.userPosts = []
            result.forEach({self.userPosts.append(MutableStatus($0))})
            result.forEach({item in
                if !item.mediaAttachments.isEmpty {
                    self.dispatchGroup.enter()
                    KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: URL(string: item.mediaAttachments[0].previewURL)!, cacheKey: item.mediaAttachments[0].previewURL), completionHandler: {_ in
                        self.dispatchGroup.leave()
                    })
                }
            })
            
            self.dispatchGroup.leave()
        })
        dispatchGroup.enter()
        newAPIHandler.getUserPosts(withID: user!.id, onlyMedia: true, range: .limit(40), completionHandler: {result in
            guard let result = result else {
                return
            }
            self.userMediaPosts = []
            result.forEach({self.userMediaPosts.append(MutableStatus($0))})
            result.forEach({item in
                if !item.mediaAttachments.isEmpty {
                    self.dispatchGroup.enter()
                    KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: URL(string: item.mediaAttachments[0].previewURL)!, cacheKey: item.mediaAttachments[0].previewURL), completionHandler: {_ in
                        self.dispatchGroup.leave()
                    })
                }
            })
            
            self.dispatchGroup.leave()
        })
        self.dispatchGroup.leave()
    }
    
    func getNextPosts(_ id: String, mediaOnly: Bool) {
        
        newAPIHandler.getUserPosts(withID: user!.id, onlyMedia: mediaOnly , range: .max(id: id, limit: 40), completionHandler: {statuses in
            guard let statuses = statuses else {
                return
            }
//            if !statuses.isEmpty {
//                statuses.removeFirst()
//            }
            var indexes: [IndexPath] = []
            for i in 0..<statuses.count {
                indexes.append(IndexPath(item: (mediaOnly ? self.userMediaPosts.endIndex : self.userPosts.endIndex) + i, section: 0))
            }
            if mediaOnly {
                statuses.forEach({self.userMediaPosts.append(MutableStatus($0))})
            } else {
                statuses.forEach({self.userPosts.append(MutableStatus($0))})
            }
            self.dispatchGroup.enter()
            statuses.forEach({item in
                if !item.mediaAttachments.isEmpty {
                    self.dispatchGroup.enter()
                    KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: URL(string: item.mediaAttachments[0].previewURL)!, cacheKey: item.mediaAttachments[0].previewURL), completionHandler: {_ in
                        self.dispatchGroup.leave()
                    })
                }
            })
            
            self.dispatchGroup.notify(queue: DispatchQueue.main, execute: {
                self.profile.isUserInteractionEnabled = false
                self.profile.performBatchUpdates({
                    self.profile.insertItems(at: indexes)
                    self.profile.isHidden = false
                }, completion: {result in
                    self.profile.isUserInteractionEnabled = true
                })
            })
            self.dispatchGroup.leave()
        })
    }
    
    @objc func logOut(_ sender: BackItem) {
        sender.showAnimation {
            
            self.newAPIHandler.logOut() {
                DispatchQueue.main.async {
                    let newVC = self.storyboard?.instantiateViewController(identifier: "ViewController")
                    UIApplication.shared.delegate?.window??.rootViewController = newVC
                }
            }
        }
    }
    
    @objc func backTapped(_ sender: BackItem) {
        sender.showAnimation({
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let layout = profile.collectionViewLayout as! PinterestLayout
        if layout.mode == .collectionView {
            return userMediaPosts.count
        } else {
            return userPosts.count
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return user != nil ? 1 : 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (profile.collectionViewLayout as! PinterestLayout).mode == .collectionView {
//            if indexPath.item == userMediaPosts.endIndex - 1 {
//                getNextPosts(userMediaPosts[indexPath.item].id, mediaOnly: true)
//            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileSample", for: indexPath) as! ProfileCell
            
            cell.mainImage.kf.cancelDownloadTask()
            cell.mainImage.kf.setImage(with: ImageResource(downloadURL: URL(string: userMediaPosts[indexPath.item].mediaAttachments[0].previewURL)!, cacheKey: userMediaPosts[indexPath.item].mediaAttachments[0].previewURL), placeholder: UIImage(named: "new7"))
            return cell
        }
//        if indexPath.item == userPosts.endIndex - 1 {
//            getNextPosts(userPosts[indexPath.item].id, mediaOnly: false)
//        }
        if userPosts[indexPath.item].mediaAttachments.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCellWithoutContent", for: indexPath) as! FeedCellWithoutContent
            cell.post = userPosts[indexPath.item]
            cell.delegate = self
            cell.fill()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedSample", for: indexPath) as! FeedCell
            cell.post = userPosts[indexPath.item]
            cell.delegate = self
            cell.fill()
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SupplementarySample", for: indexPath) as! SupplementaryView
        reusableView.myDelegate = self
        reusableView.user = user
        reusableView.fill()
        return reusableView
    }
}

// MARK: - UICollectionViewDelegate

extension ProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print(indexPath.item)
        guard let layout = collectionView.collectionViewLayout as? PinterestLayout else {
            return
        }
        let index = IndexPath(item: indexPath.item - 1, section: 0)
        guard (collectionView.cellForItem(at: index) != nil) else {
            return
        }
        print("getting")
        if layout.mode == .tableView {
            if userPosts.endIndex - 1 == indexPath.item {
                getNextPosts(userPosts[indexPath.item].id, mediaOnly: false)
            }
        } else if layout.mode == .collectionView {
            if userMediaPosts.endIndex - 1 == indexPath.item {
                getNextPosts(userMediaPosts[indexPath.item].id, mediaOnly: true)
            }
        }
    }
    
}

// MARK: - HeaderDelegate

extension ProfileViewController: HeaderDelegate {
    func segmentedControlPressed(withIndex index: Int) {
        let layout = profile.collectionViewLayout as! PinterestLayout
        if index == 0 {
            layout.mode = .tableView
            
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.profile.collectionViewLayout.invalidateLayout()
            })
            self.profile.reloadData()
            CATransaction.commit()
        } else {
            layout.mode = .collectionView
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.profile.collectionViewLayout.invalidateLayout()
            })
            self.profile.reloadData()
            CATransaction.commit()
        }
    }
    
    
    func toTable(userId: String, rCase: UsersTableViewController.RetrievingCase, sender: UIView) {
        sender.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0, delay: 0, options: [], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        }, completion: {_ in
            UIView.animate(withDuration: 0.05, delay: 0, options: [.curveLinear], animations: {
                sender.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: {_ in
                self.newAPIHandler.getUser(withID: userId, completionHandler: {user in
                    guard let user = user else {
                        sender.isUserInteractionEnabled = true
                        return
                    }
                    DispatchQueue.main.async {
                        let newVC = self.storyboard?.instantiateViewController(identifier: "TableController") as! UsersTableViewController
                        newVC.hostUser = user
                        newVC.retrievingCase = rCase
                        self.navigationController?.pushViewController(newVC, animated: true)
                        sender.isUserInteractionEnabled = true
                    }
                })
            })
        })
    }
    
}

extension ProfileViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeForPhotoAtIndexPath indexPath: IndexPath) -> CGSize {
        guard let layout = collectionView.collectionViewLayout as? PinterestLayout else {
            return CGSize(width: 1, height: 1)
        }
        if layout.mode == .collectionView {
            var retrievedImage: UIImage?
//            dispatchGroup.enter()
            ImageCache.default.retrieveImage(forKey: userMediaPosts[indexPath.item].mediaAttachments[0].previewURL, completionHandler: {result in
                switch result {
                case .success(let imageCache):
                    switch imageCache {
                    case .disk(let image):
                        retrievedImage = image
                    case .memory(let image):
                        retrievedImage = image
                    default:
                        break
                    }
                case .failure(let error):
                    self.generateAlert(title: "Retrieving image error", message: error.errorDescription ?? "smth else", buttonTitle: "OK")
                }
//                self.dispatchGroup.leave()
            })
//            dispatchGroup.wait()
            return retrievedImage != nil ? retrievedImage!.size : CGSize(width: 1, height: 1)
        } else {
            if userPosts[indexPath.item].mediaAttachments.isEmpty {
                let cell = UINib(nibName: "FeedCellWithoutContent", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! FeedCellWithoutContent
                cell.frame.size = CGSize(width: collectionView.frame.width - layout.cellPadding * 2, height: collectionView.frame.height)
                cell.widthAnchor.constraint(equalToConstant: collectionView.frame.width - layout.cellPadding * 2).isActive = true
                cell.post = userPosts[indexPath.item]
                cell.fill()
                cell.layoutSubviews()
                return cell.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
            } else {
//                dispatchGroup.enter()
                let cell = UINib(nibName: "FeedCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! FeedCell
                cell.frame.size = CGSize(width: collectionView.frame.width - layout.cellPadding * 2, height: collectionView.frame.height)
                cell.translatesAutoresizingMaskIntoConstraints = false
                cell.widthAnchor.constraint(equalToConstant: collectionView.frame.width - layout.cellPadding * 2).isActive = true
                cell.post = userPosts[indexPath.item]
                cell.fill({
//                    self.dispatchGroup.leave()
                })
//                dispatchGroup.wait()
                cell.layoutSubviews()
                let aspectRatio = cell.mainImage.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width / cell.mainImage.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
                let layout = collectionView.collectionViewLayout as! PinterestLayout
                let height = (collectionView.frame.width - layout.cellPadding * 2) / aspectRatio
                let difference = height - cell.mainImage.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
                let cellFinalSize = CGSize(width: collectionView.frame.width - layout.cellPadding * 2, height: cell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + difference)
                return cellFinalSize
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, kind: String, sizeForTextAtIndexPath indexPath: IndexPath) -> CGSize? {
        
        let supplementaryView = UINib(nibName: "SupplementaryView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! SupplementaryView
        supplementaryView.frame.size = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
//        supplementaryView.translatesAutoresizingMaskIntoConstraints = false
        supplementaryView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        supplementaryView.user = user
        supplementaryView.fill()
        supplementaryView.layoutSubviews()
        return supplementaryView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
    }
}

extension ProfileViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//        for item in indexPaths {
//            dispatchGroup.enter()
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileSample", for: item) as! ProfileCell
//            cell.mainImage.kf.setImage(with: ImageResource(downloadURL: URL(string: userPosts[item.item].mediaAttachments[0].previewURL)!, cacheKey: userPosts[item.item].mediaAttachments[0].previewURL), completionHandler: {result in
//                self.dispatchGroup.leave()
//            })
//        }
//        dispatchGroup.notify(queue: DispatchQueue.main, execute: {
//            self.profile.collectionViewLayout.invalidateLayout()
//        })
//
    }
}

extension ProfileViewController: FeedCellDelegate {
    func toAuthorProfile(withID id: String) {
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
    
    func toLikes(ofPostID id: String) {
        DispatchQueue.main.async {
            let newVC = self.storyboard?.instantiateViewController(identifier: "TableController") as! UsersTableViewController
            newVC.retrievingCase = .likes(id)
            self.navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    
}

