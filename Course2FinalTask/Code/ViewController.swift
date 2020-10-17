//
//  ViewController.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 16.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

import MastodonKit
import p2_OAuth2
import AuthenticationServices
import LocalAuthentication

class ViewController: UIViewController {
    
    var mastodonApiHandler: Client!
    let clientID = "ac4DFdmEXNquMLFjYkRJFEqntn6gookPIxj_QeZlOwc"
    let clientSecret = "TfwMrdebdWkMIjC4TDW7pkFdw5QCx1tzqQOyg2z97r4"
    @IBOutlet weak var logInButton: BackItem!
    @IBOutlet weak var serverNameField: UITextField!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logInButton.font = UIFont(name: "Futura-Bold", size: 20)
        logInButton.isEnabled = false
        serverNameField.isEnabled = false
        serverNameField.delegate = self
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let check = checkKeychain()
        print("token check: \(check)")
        if check.0 {
            mastodonApiHandler = Client(baseURL: "https://\(check.2)", accessToken: check.1, session: URLSession.shared)
            let request = Accounts.currentUser()
            mastodonApiHandler.run(request, completion: {result in
                switch result {
                case .success(_, _):
                    
                    DispatchQueue.main.async {
                        let newVC = self.storyboard?.instantiateViewController(identifier: "TabBarController") as! TabBarController
                        UITabBar.setTransparentTabBar()
                        UINavigationBar.setTransparentNavigationBar()
                        UITabBar.appearance().tintColor = UIColor(named: "liked")
                        newVC.mastodonApiHandler = NewAPIHandler(accessToken: check.1, clientID: self.clientID, clientSecret: self.clientSecret, server: "https://\(check.2)", completionHandler: {
                            let context = LAContext()
                            context.localizedCancelTitle = "Enter Username/Password"
                            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
                                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Log in to your account", reply: {success, error in
                                    if success {
                                        DispatchQueue.main.async {
            //                                biometric authentification goes here
                                            UIApplication.shared.delegate?.window??.rootViewController = newVC
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            UIView.animate(withDuration: 1.5, animations: {
                                                self.logInButton.alpha = 1
                                                self.serverNameField.alpha = 1
                                                self.label.alpha = 1
                                            }, completion: {_ in
                                                self.logInButton.isEnabled = true
                                                self.serverNameField.isEnabled = true
                                            })
                                        }
                                    }
                                })
                            } else {
                                DispatchQueue.main.async {
    //                                biometric authentification goes here
                                    UIApplication.shared.delegate?.window??.rootViewController = newVC
                                }
                            }
                        })
                    }
                    return
                case .failure(_):
                    self.tokenToKeychain(.delete)
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 1.5, animations: {
                            self.logInButton.alpha = 1
                            self.serverNameField.alpha = 1
                            self.label.alpha = 1
                        }, completion: {_ in
                            self.logInButton.isEnabled = true
                            self.serverNameField.isEnabled = true
                        })
                    }
                }
            })
        } else {
            UIView.animate(withDuration: 1.5, animations: {
                self.logInButton.alpha = 1
                self.serverNameField.alpha = 1
                self.label.alpha = 1
            }, completion: {_ in
                self.logInButton.isEnabled = true
                self.serverNameField.isEnabled = true
            })
        }
    }
    
    @IBAction func logInButtonPressed(_ sender: BackItem) {
        sender.showAnimation {
            guard let server = self.serverNameField.text, !server.isEmpty else {
                return
            }
            self.logIn(server: server)
        }
    }
    
    private func logIn(server: String) {
        let url = URL(string: "https://\(server)/oauth/authorize?client_id=\(clientID)&scope=read+write+follow&redirect_uri=photonetwork://oauth-callback&response_type=code")!
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "photonetwork") { callbackURL, error in
            guard error == nil, let url = callbackURL else {
                print("nothing")
                print(error?.localizedDescription)
                return
            }
            guard let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.filter({$0.name == "code"}).first?.value else {
                return
            }
            print("url: \(code)")
            let request = Login.oauth(clientID: self.clientID, clientSecret: self.clientSecret, scopes: [.read, .write, .follow], redirectURI: "photonetwork://oauth-callback", code: code)
            self.mastodonApiHandler = Client(baseURL: "https://\(server)")
            self.mastodonApiHandler.run(request) { result in
                switch result {
                case .success(let settings, _):
                    print(settings.accessToken)
                    self.mastodonApiHandler.accessToken = settings.accessToken
                    self.tokenToKeychain(.delete)
                    self.tokenToKeychain(.add, token: settings.accessToken)
                    DispatchQueue.main.async {
                        let newVC = self.storyboard?.instantiateViewController(identifier: "TabBarController") as! TabBarController
                        UITabBar.setTransparentTabBar()
                        UINavigationBar.setTransparentNavigationBar()
                        UITabBar.appearance().tintColor = UIColor(named: "liked")
                        newVC.mastodonApiHandler = NewAPIHandler(accessToken: settings.accessToken, clientID: self.clientID, clientSecret: self.clientSecret, server: "https://\(server)", completionHandler: {
                            print("in the completion")
                            DispatchQueue.main.async {
                                print("changing viewcontroller")
                                UIApplication.shared.delegate?.window??.rootViewController = newVC
                            }
                        })
                        
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        session.prefersEphemeralWebBrowserSession = true
        session.presentationContextProvider = self
        session.start()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func checkKeychain() -> (Bool, String, String) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: "Mastodon" as Any,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true
                                    ]
        
        var queryResult: AnyObject?
        
        let status = SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer(&queryResult))
        print("check status: \(status)")
        if status == errSecSuccess {
            guard let result = queryResult as? [String: Any], let tokenData = result[kSecValueData as String] as? Data, let token = String(data: tokenData, encoding: .utf8), let server = result[kSecAttrAccount as String] as? String else {
                return (false, "", "")
            }
            return (true, token, server)
        } else {
            return (false, "", "")
        }
    }
    
    private func tokenToKeychain(_ scenario: Scenario, token: String = "") {
        DispatchQueue.main.async {
            var query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                     kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
                     kSecAttrService as String: "Mastodon" as Any
                     ]
            switch scenario {
            case .add:
                query[kSecAttrAccount as String] = self.serverNameField.text as Any
                query[kSecValueData as String] = token.data(using: .utf8) as Any
                let response = SecItemAdd(query as CFDictionary, nil)
                print("add status: \(response)")
            case .update:
                let attributesToUpdate = [kSecValueData as String: token.data(using: .utf8) as Any,
                                          kSecAttrAccount as String: self.serverNameField.text as Any]
                let response = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
                print("update status: \(response)")
            case .delete:
                let response = SecItemDelete(query as CFDictionary)
                print("delete status: \(response)")
            }
        }
    }
    
    private enum Scenario {
        case add
        case update
        case delete
    }

}

extension ViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        logIn(server: textField.text ?? "")
        return true
    }
}
