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
    @IBOutlet weak var usernameTitle: UINavigationItem!
    let apiHandler = APIHandler()
    let newAPIHandler = NewAPIHandler()
    let dispatchGroup = DispatchGroup()
    var user: Account? {
        didSet {
            newAPIHandler.getUserPosts(withID: user!.id, onlyMedia: true, range: .limit(40), completionHandler: {result in
                self.userPosts = result
                result.forEach({_ in
                    self.dispatchGroup.enter()
                })
                self.dispatchGroup.notify(queue: DispatchQueue.main, execute: {
                    print("notified")
                    (self.profile.collectionViewLayout as! PinterestLayout).invalidateLayout()
                })
                DispatchQueue.main.async {
                    CATransaction.begin()
                    CATransaction.setCompletionBlock({
                        print("reload completed")
//                        (self.profile.collectionViewLayout as! PinterestLayout).invalidateLayout()
                    })
                    print("reloading")
                    self.profile.reloadData()
                    CATransaction.commit()
                }
                
            })
        }
    }
    var userPosts:[Status] = []
    var indexForRow: IndexPath?

    // MARK: - View configuration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UITraitCollection.current.userInterfaceStyle == .dark {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "nightcopy.png")!)
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "daycopy.png")!)
        }
        profile.backgroundColor = .clear
        newAPIHandler.delegate = self
//        let layout = profile.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.estimatedItemSize = CGSize(width: 1, height: 1)
        if let layout = profile.collectionViewLayout as? PinterestLayout {
            layout.delegate = self
        }
        profile.dataSource = self
        profile.delegate = self
        profile.register(UINib(nibName: "ProfileCell", bundle: nil), forCellWithReuseIdentifier: "ProfileSample")
        profile.register(UINib(nibName: "SupplementaryView", bundle: nil), forSupplementaryViewOfKind: "Header", withReuseIdentifier: "SupplementarySample")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.logOut))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17)], for: .normal)
        self.navigationItem.rightBarButtonItem?.tintColor = .systemBlue
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        if user == nil {
//            newAPIHandler.getUser(withID: NewAPIHandler.currentUserID ?? "", completionHandler: {result in
//                self.user = result
//            })
//        }
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
    
    @objc func logOut() {
    }
    @IBAction func button(_ sender: UIButton) {
        newAPIHandler.getUser(withID: NewAPIHandler.currentUserID ?? "", completionHandler: {result in
            self.user = result
        })
    }
    
    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPosts.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return user != nil ? 1 : 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileSample", for: indexPath) as! ProfileCell
        cell.mainImage.kf.setImage(with: ImageResource(downloadURL: URL(string: userPosts[indexPath.item].mediaAttachments[0].previewURL)!, cacheKey: userPosts[indexPath.item].mediaAttachments[0].previewURL), completionHandler: {result in
            switch result {
            case .success(let resultObject):
                self.dispatchGroup.leave()
            case .failure(let error):
                print("error: \(error.errorDescription)")
            }
        })
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SupplementarySample", for: indexPath) as! SupplementaryView
        reusableView.myDelegate = self
        reusableView.user = user
        reusableView.fill()
        return reusableView
    }
}

extension ProfileViewController: UICollectionViewDelegate {}

    // MARK: - UICollectionViewDelegateFlowLayout

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if let cell = collectionView.cellForItem(at: indexPath) as? ProfileCell {
//            print("here")
//            let aspectRation = cell.mainImage.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).width / cell.mainImage.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height
//            let width = collectionView.frame.width / 3
//            print("size of item \(indexPath.item): desirable \(cell.mainImage.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)), real \(cell.mainImage.frame.size), modified \(CGSize(width: width, height: width / aspectRation))")
//            return CGSize(width: width, height: width / aspectRation)
//        } else {
//            return CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.width / 3)
//        }
//        
//    }

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

    // MARK: - HeaderDelegate

extension ProfileViewController: HeaderDelegate {
    
    func toTable(userId: String, title: String) {
//        let newVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableController") as! UsersTableViewController
//        switch title {
//        case "Followers":
//            newVC.navigationItem.title = title
//            apiHandler.get(.followers, withID: userId, completionHandler: {users in
//                guard let followers = users as? [User] else {
//                    self.generateAlert(title: "Oops!", message: "Something with decoding JSON.", buttonTitle: "OK")
//                    return
//                }
//                DispatchQueue.main.async {
//                    newVC.data = followers
//                    newVC.hostUser = userId
//                    let backButtonTitle = self.navigationItem.title
//                    self.navigationController?.pushViewController(newVC, animated: true)
//
//                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
//                    self.navigationItem.backBarButtonItem?.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17)], for: .normal)
//                    self.navigationItem.backBarButtonItem?.tintColor = .systemBlue
//                }
//            })
//            
//        case "Following":
//            newVC.navigationItem.title = title
//            apiHandler.get(.following, withID: userId, completionHandler: {users in
//                guard let followers = users as? [User] else {
//                    self.generateAlert(title: "Oops!", message: "Something with decoding JSON.", buttonTitle: "OK")
//                    return
//                }
//                DispatchQueue.main.async {
//                    newVC.data = followers
//                    newVC.hostUser = userId
//                    let backButtonTitle = self.navigationItem.title
//                    self.navigationController?.pushViewController(newVC, animated: true)
//                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
//                    self.navigationItem.backBarButtonItem?.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17)], for: .normal)
//                    self.navigationItem.backBarButtonItem?.tintColor = .systemBlue
//                }
//            })
//        default:
//            print("SMTH WRONG! ! ! !")
//            newVC.navigationItem.title = title
//            newVC.data = []
//            let backButtonTitle = self.navigationItem.title
//            self.navigationController?.pushViewController(newVC, animated: true)
//            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: backButtonTitle, style: UIBarButtonItem.Style.plain, target: nil, action: nil)
//            self.navigationItem.backBarButtonItem?.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17)], for: .normal)
//            self.navigationItem.backBarButtonItem?.tintColor = .systemBlue
//        }
    }
}

extension ProfileViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeForPhotoAtIndexPath indexPath: IndexPath) -> CGSize {

        guard let cell = collectionView.cellForItem(at: indexPath) as? ProfileCell else {
            print(0)
            return CGSize(width: 1, height: 1)
        }
        guard let size = cell.mainImage?.image?.size else {
            print(1)
            return CGSize(width: 1, height: 1)
        }
        print("cell size: \(size)")
        return size
    }
    func collectionView(_ collectionView: UICollectionView, kind: String, sizeForTextAtIndexPath indexPath: IndexPath) -> CGSize {
        guard let supplementaryView = collectionView.supplementaryView(forElementKind: kind, at: indexPath) as? SupplementaryView else {
            print(2)
            return CGSize(width: collectionView.frame.width, height: 201)
        }
        let calculatedHeightOfAvatar = supplementaryView.avatar.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height
        let calculatedHeightOfFullName = supplementaryView.fullName.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height
        let calculatedHeightOfUsername = supplementaryView.username.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height
        let calculatedHeightOfNote = supplementaryView.note.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height
        let calculatedHeightOfFollowers = supplementaryView.followers.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height
        let calculatedHeightOfSegmentedControl = supplementaryView.postsOrMediaSegmentedControl.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize).height
        let totalSize = calculatedHeightOfAvatar + calculatedHeightOfFullName + calculatedHeightOfUsername + calculatedHeightOfNote + calculatedHeightOfFollowers + calculatedHeightOfSegmentedControl
        let size = CGSize(width: collectionView.frame.width, height: totalSize + 140)
        print("size: \(size), heights: avatar - \(supplementaryView.avatar.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)), fullname - \(supplementaryView.fullName.frame.size.height)")
        print("main view size: \(supplementaryView.mainView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize))")
        return size
    }
}

