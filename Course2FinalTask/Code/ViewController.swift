//
//  ViewController.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 16.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

import MastodonKit
import OAuth2

class ViewController: UIViewController {

    var oAuth2: OAuth2CodeGrant!
    
    var mastodonApiHandler: Client?
    
    @IBOutlet weak var request: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        if mastodonApiHandler == nil {
            request.isHidden = true
        }
        oAuth2.authConfig.authorizeEmbedded = true
        oAuth2.authConfig.ui.modalPresentationStyle = .pageSheet
        oAuth2.authConfig.authorizeContext = self
        // Do any additional setup after loading the view.
    }
    

    @IBAction func button(_ sender: Any) {
        oAuth2.forgetTokens()
        oAuth2.authorizeEmbedded(from: self, callback: {json, error in
            guard var data = json else {
                print(error!.description)
                return
            }
            if data.isEmpty {
                data["access_token"] = self.oAuth2.accessToken!
            }
            print(data)
            self.mastodonApiHandler = Client(baseURL: "https://mstdn.social", accessToken: (data["access_token"] as! String))
            NewAPIHandler(accessToken: data["access_token"] as! String, completionHandler: {
                DispatchQueue.main.async {
                    let newVC = self.storyboard?.instantiateViewController(identifier: "FeedViewController") as! FeedViewController
                    newVC.modalPresentationStyle = .fullScreen
                    self.request.isHidden = false
                    self.present(newVC, animated: true, completion: nil)
                }
            })
            
        })
    }
    @IBAction func request(_ sender: Any) {
        let request = Accounts.currentUser()
        mastodonApiHandler?.run(request, completion: {result in
            switch result {
            case .success(let account, _):
                print(account.displayName)
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
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
