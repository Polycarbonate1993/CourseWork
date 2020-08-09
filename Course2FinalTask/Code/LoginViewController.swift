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
        setUpState()
    }
    
    @IBAction func signInPressed(_ sender: Any) {
        apiHandler.signin(username: loginField.text ?? "", password: passwordField.text ?? "", completionHandler: {
            if APIHandler.token != nil {
                print(APIHandler.token ?? "")
                let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
                                            kSecAttrDescription as String: "Auithorization token" as Any,
                                            kSecValueData as String: APIHandler.token?.data(using: .utf8) as Any
                ]
                let status = SecItemAdd(query as CFDictionary, nil)
                print("adding status: \(SecCopyErrorMessageString(status, nil) ?? "" as CFString)")
                DispatchQueue.main.async {
                    let newVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
                    NotificationCenter.default.removeObserver(self)
                    newVC.dataManager = CoreDataManager(modelName: "Model")
                    UIApplication.shared.delegate?.window??.rootViewController = newVC
                }
            }
        })
    }
    
    private func setUpState() {
        var query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrDescription as String: "Auithorization token" as Any,
                                    kSecReturnAttributes as String: true,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnData as String: true
        ]
        var queryResult: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer(&queryResult))
        print("keychain status: \(SecCopyErrorMessageString(status, nil) ?? "" as CFString)")
        
        if status == errSecSuccess {
            print("smth")
            guard let item = queryResult as? [String: Any], let tokenData = item[kSecValueData as String] as? Data, let token = String(data: tokenData, encoding: .utf8) else {
                return
            }
            DispatchQueue.main.async {
                Spinner.start()
            }
            apiHandler.checkToken(token, completionHandler: {tokenCheck in
                DispatchQueue.main.async {
                    Spinner.stop()
                }
                switch tokenCheck {
                case .valid:
                    APIHandler.token = token
                    self.apiHandler.get(.user, completionHandler: {user in
                        guard let currentUser = user as? User else {
                            self.tabBarController?.generateAlert(title: "Oops!", message: "Error trying to decode JSON.", buttonTitle: "OK")
                            return
                        }
                        APIHandler.currentUserId = currentUser.id
                        DispatchQueue.main.async {
                            let newVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
                            NotificationCenter.default.removeObserver(self)
                            newVC.dataManager = CoreDataManager(modelName: "Model")
                            UIApplication.shared.delegate?.window??.rootViewController = newVC
                        }
                    })
                case .invalid:
                    query = [kSecClass as String: kSecClassInternetPassword,
                             kSecAttrDescription as String: "Auithorization token" as Any,
                    ]
                    let deletionStatus = SecItemDelete(query as CFDictionary)
                    print("deletion status: \(SecCopyErrorMessageString(deletionStatus, nil) ?? "" as CFString)")
                case .offlineMode:
                    DispatchQueue.main.async {
                        let newVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
                        NotificationCenter.default.removeObserver(self)
                        newVC.dataManager = CoreDataManager(modelName: "Model")
                        UIApplication.shared.delegate?.window??.rootViewController = newVC
                        newVC.generateAlert(title: "Offline Mode", message: "Functionality is limited.", buttonTitle: "OK")
                    }
                }
            })
        }
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
                    let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
                                                kSecAttrDescription as String: "Auithorization token" as Any,
                                                kSecValueData as String: APIHandler.token?.data(using: .utf8) as Any
                    ]
                    let status = SecItemAdd(query as CFDictionary, nil)
                    print("adding status: \(SecCopyErrorMessageString(status, nil) ?? "" as CFString)")
                    DispatchQueue.main.async {
                        let newVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
                        NotificationCenter.default.removeObserver(self)
                        newVC.dataManager = CoreDataManager(modelName: "Model")
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
