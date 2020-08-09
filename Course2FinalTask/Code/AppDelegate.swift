//
//  AppDelegate.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

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
    func importFromCoreDataToJSON<T: DecodedJSONData>(_ typeSelected: T.Type) -> [T] {
        if let posts = self as? [CoreDataPost] {
            var newArray: [Post] = []
            for item in posts {
                let post = Post()
                post.author = item.author
                post.authorAvatar = (item.authorAvatar!).base64EncodedString()
                post.authorUsername = item.authorUsername
                post.createdTime = item.createdTime
                post.currentUserLikesThisPost = item.currentUserLikesThisPost
                post.description = item.postDescription
                post.id = item.id
                post.image = (item.image!).base64EncodedString()
                post.likedByCount = Int(item.likedByCount)
                newArray.append(post)
            }
            return newArray as! [T]
        } else if let users = self as? [CoreDataUser] {
            var newArray: [User] = []
            for item in users {
                let user = User()
                user.avatar = (item.avatar!).base64EncodedString()
                user.currentUserFollowsThisUser = item.currentUserFollowsThisUser
                user.currentUserIsFollowedByThisUser = item.currentUserIsFollowedByThisUser
                user.followedByCount = Int(item.followedByCount)
                user.followsCount = Int(item.followsCount)
                user.fullName = item.fullname
                user.id = item.id
                user.username = item.username
                newArray.append(user)
            }
            return newArray as! [T]
        }
        return []
    }
    
    func exportToCoreDataFromDecodedJSONData<T: NSManagedObject>(withMarker: Bool = false, _ selectedType: T.Type) -> [T] {
        if let posts = self as? [Post] {
            var newArray: [CoreDataPost] = []
            let dataManager = ((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as! TabBarController).dataManager
            for item in posts {
                let coreDataPost = dataManager!.createObject(from: CoreDataPost.self)
                coreDataPost.author = item.author
                coreDataPost.authorAvatar = fromStringURLToData(item.authorAvatar)
                coreDataPost.authorUsername = item.authorUsername
                coreDataPost.createdTime = item.createdTime
                coreDataPost.id = item.id
                coreDataPost.image = fromStringURLToData(item.image)
                coreDataPost.likedByCount = Int16(item.likedByCount)
                coreDataPost.postDescription = item.description
                coreDataPost.currentUserLikesThisPost = item.currentUserLikesThisPost
                coreDataPost.inFeed = withMarker
                newArray.append(coreDataPost)
            }
//            print(newArray)
            return newArray as! [T]
        } else if let users = self as? [User] {
            var newArray: [CoreDataUser] = []
            let dataManager = ((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as! TabBarController).dataManager!
            for item in users {
                let coreDataUser = dataManager.createObject(from: CoreDataUser.self)
                coreDataUser.avatar = fromStringURLToData(item.avatar)
                coreDataUser.currentUserFollowsThisUser = item.currentUserFollowsThisUser
                coreDataUser.currentUserIsFollowedByThisUser = item.currentUserIsFollowedByThisUser
                coreDataUser.followedByCount = Int16(item.followedByCount)
                coreDataUser.followsCount = Int16(item.followsCount)
                coreDataUser.fullname = item.fullName
                coreDataUser.id = item.id
                coreDataUser.username = item.username
                coreDataUser.isCurrentUser = withMarker
                newArray.append(coreDataUser)
            }
            print(newArray)
            return newArray as! [T]
        }
        return []
    }
}

public func fromStringURLToData(_ url: String) -> Data {
    return try! Data(contentsOf: URL(string: url)!)
}

open class Spinner {
    internal static var spinner: UIActivityIndicatorView?
    public static var style: UIActivityIndicatorView.Style = .large
    public static var baseBackColor = UIColor(white: 0, alpha: 0.6)
    public static var baseColor = UIColor.white
    
    public static func start(style: UIActivityIndicatorView.Style = style, backColor: UIColor = baseBackColor, baseColor: UIColor = baseColor) {
        if spinner == nil, let window = UIApplication.shared.windows.last {
            let frame = UIScreen.main.bounds
            spinner = UIActivityIndicatorView(frame: frame)
            spinner!.backgroundColor = backColor
            spinner!.style = style
            spinner?.color = baseColor
            window.addSubview(spinner!)
            spinner!.startAnimating()
        }
    }
    
    public static func stop() {
        if spinner != nil {
            spinner!.stopAnimating()
            spinner!.removeFromSuperview()
            spinner = nil
        }
    }
}
