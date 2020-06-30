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
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func runActivityIndicatorSafe() {
        
        DispatchQueue.main.async {
                    let activityView = UIView(frame: self.view.frame)
                    activityView.tag = 102938
                    activityView.backgroundColor = .black
                    activityView.alpha = 0.7
                    activityView.isHidden = false
                    let indicator = UIActivityIndicatorView(frame: activityView.frame)
                    indicator.isHidden = false
                    indicator.color = .white
                    indicator.hidesWhenStopped = true
                    indicator.startAnimating()
                    
                    activityView.addSubview(indicator)
                    self.view.addSubview(activityView)
                    
        //            indicator.centerXAnchor.constraint(equalTo: activityView.centerXAnchor).isActive = true
        //            indicator.centerYAnchor.constraint(equalTo: activityView.centerYAnchor).isActive = true
                    
                    
        }
        
    }
    func stopActivityindicatorSafe() {
        DispatchQueue.main.async {
            self.view.viewWithTag(102938)?.isHidden = true
            self.view.viewWithTag(102938)?.removeFromSuperview()
        }
        
        
    }
    
    func generateAlert(title: String, message: String, buttonTitle: String, activity: Bool = false) {
        DispatchQueue.main.async {
            if activity {
                self.navigationController?.stopActivityindicatorSafe()
            }
            let newVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            newVC.addAction(UIAlertAction(title: buttonTitle, style: .cancel, handler: { action in
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }))
            
            self.present(newVC, animated: true, completion: nil)
        }
        
        
    }
}

