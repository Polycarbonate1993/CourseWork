//
//  AppDelegate.swift
//  Course2FinalTask
//
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit

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

