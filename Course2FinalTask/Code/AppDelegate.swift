//
//  AppDelegate.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let LoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        
        window?.rootViewController = LoginViewController
        
        window?.makeKeyAndVisible()
        
        return true
    }
}

extension UIViewController {
    
    // MARK: - Usefull extensions to UIViewController
    
    /**Enables hiding keyboard on tapping anywhere on the screen.*/
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    

    /// Creates an alert with given title, message and button title and shows it on the screen.
    ///
    /// - Parameters:
    ///   - title: Title of the alert.
    ///   - message: The message of the alert.
    ///   - buttonTitle: The text that appears on the button.
    ///
    func generateAlert(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let newVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            newVC.addAction(UIAlertAction(title: buttonTitle, style: .cancel, handler: { action in
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }))
            self.present(newVC, animated: true, completion: nil)
        }
    }
}

extension Array {
    func convertFromCoreData<T: DecodedJSONData>(to: T.Type) -> [T] {
        var newArray: [T] = []
        if let coreDataArray = self as? [CoreDataPost] {
            for item in coreDataArray {
                let post = Post()
                post.author = item.author
                post.authorAvatar = item.authorAvatar
                post.authorUsername = item.authorUsername
                post.createdTime = item.createdTime
                post.currentUserLikesThisPost = item.currentUserLikesThisPost
                post.description = item.postDescription
                post.id = item.id
                post.image = item.image
                post.likedByCount = Int(item.likedByCount)
                newArray.append(post as! T)
            }
        } else if let coreDataArray = self as? [CoreDataUser] {
            for item in coreDataArray {
                let user = User()
                user.avatar = item.avatar
                user.currentUserFollowsThisUser = item.currentUserFollowsThisUser
                user.currentUserIsFollowedByThisUser = item.currentUserIsFollowedByThisUser
                user.followedByCount = Int(item.followedByCount)
                user.followsCount = Int(item.followsCount)
                user.fullName = item.fullname
                user.id = item.id
                user.username = item.username
                newArray.append(user as! T)
            }
        }
        return newArray
    }
    
    func convertFromJSON<T: NSManagedObject>(to: [T]) {
        if self.count == to.count {
            if let jsonArray = self as? [Post], let coreDataArray = to as? [CoreDataPost] {
                for i in 0..<coreDataArray.count {
                    coreDataArray[i].author = jsonArray[i].author
                    coreDataArray[i].authorAvatar = jsonArray[i].authorAvatar
                    coreDataArray[i].authorUsername = jsonArray[i].authorUsername
                    coreDataArray[i].createdTime = jsonArray[i].createdTime
                    coreDataArray[i].id = jsonArray[i].id
                    coreDataArray[i].image = jsonArray[i].image
                    coreDataArray[i].likedByCount = Int16(jsonArray[i].likedByCount)
                    coreDataArray[i].postDescription = jsonArray[i].description
                    coreDataArray[i].currentUserLikesThisPost = jsonArray[i].currentUserLikesThisPost
                }
            } else if let jsonArray = self as? [User], let coreDataArray = to as? [CoreDataUser] {
                for i in 0..<coreDataArray.count {
                    coreDataArray[i].avatar = jsonArray[i].avatar
                    coreDataArray[i].currentUserFollowsThisUser = jsonArray[i].currentUserFollowsThisUser
                    coreDataArray[i].currentUserIsFollowedByThisUser = jsonArray[i].currentUserIsFollowedByThisUser
                    coreDataArray[i].followedByCount = Int16(jsonArray[i].followedByCount)
                    coreDataArray[i].followsCount = Int16(jsonArray[i].followsCount)
                    coreDataArray[i].fullname = jsonArray[i].fullName
                    coreDataArray[i].id = jsonArray[i].id
                    coreDataArray[i].username = jsonArray[i].username
                }
            }
        }
    }
}

