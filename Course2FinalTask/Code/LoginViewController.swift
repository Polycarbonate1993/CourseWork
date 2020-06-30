//
//  LoginViewController.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 26.06.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController {

    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    var apiHandler = APIHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(textLoginDidChange(notification:)), name: UITextField.textDidChangeNotification, object: loginField)
        NotificationCenter.default.addObserver(self, selector: #selector(textPasswordDidChange(notification:)), name: UITextField.textDidChangeNotification, object: passwordField)
        self.hideKeyboardWhenTappedAround()
        apiHandler.delegate = self
        signInButton.alpha = 0.3
        signInButton.isEnabled = false

        // Do any additional setup after loading the view.
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
