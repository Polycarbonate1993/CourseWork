//
//  LoginViewController.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 26.06.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {

    // MARK: - Outlets and properties
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    var apiHandler = APIHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(textLoginDidChange(notification:)), name: UITextField.textDidChangeNotification, object: loginField)
        NotificationCenter.default.addObserver(self, selector: #selector(textPasswordDidChange(notification:)), name: UITextField.textDidChangeNotification, object: passwordField)
        self.hideKeyboardWhenTappedAround()
        loginField.delegate = self
        passwordField.delegate = self
        apiHandler.delegate = self
        signInButton.alpha = 0.3
        signInButton.isEnabled = false
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        apiHandler.signin(username: loginField.text ?? "", password: passwordField.text ?? "", completionHandler: {
            if APIHandler.token != nil {
                print(APIHandler.token ?? "")
                DispatchQueue.main.async {
                    let newVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
                    NotificationCenter.default.removeObserver(self)
                    UIApplication.shared.delegate?.window??.rootViewController = newVC
                }
            }
        })
    }
    // MARK: - Observing text fields changes
    
    @objc func textLoginDidChange(notification: Notification) {
        guard let textField = notification.object as? UITextField else {
            print("not textField")
            return
        }
        if textField.text != "" {
            if passwordField.text != "" {
                signInButton.alpha = 1
                signInButton.isEnabled = true
            } else {
                signInButton.alpha = 0.3
                signInButton.isEnabled = false
            }
        } else {
            signInButton.alpha = 0.3
            signInButton.isEnabled = false
        }
    }
    
    @objc func textPasswordDidChange(notification: Notification) {
        guard let textField = notification.object as? UITextField else {
            print("not textField")
            return
        }
        if textField.text != "" {
            if loginField.text != "" {
                signInButton.alpha = 1
                signInButton.isEnabled = true
            } else {
                signInButton.alpha = 0.3
                signInButton.isEnabled = false
            }
        } else {
            signInButton.alpha = 0.3
            signInButton.isEnabled = false
        }
    }
}

    // MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if loginField.text != "" && passwordField.text != "" {
            apiHandler.signin(username: loginField.text ?? "", password: passwordField.text ?? "", completionHandler: {
                if APIHandler.token != nil {
                    print(APIHandler.token ?? "")
                    DispatchQueue.main.async {
                        let newVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
                        NotificationCenter.default.removeObserver(self)
                        UIApplication.shared.delegate?.window??.rootViewController = newVC
                    }
                }
            })
            return true
        } else {
            return false
        }
    }
}
