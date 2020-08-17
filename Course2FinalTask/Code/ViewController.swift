//
//  ViewController.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 16.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit
import OAuthSwift

class ViewController: OAuthViewController {
    var oauthSwift: OAuth1Swift!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func button(_ sender: Any) {
        let oauth = OAuth1Swift(consumerKey: "c9a7b8ee063f37008571b52fb74ab265", consumerSecret: "2d348200430ad573", requestTokenUrl: "https://www.flickr.com/services/oauth/request_token", authorizeUrl: "https://www.flickr.com/services/oauth/authorize", accessTokenUrl: "https://www.flickr.com/services/oauth/access_token")
        oauthSwift = oauth
        oauth.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauth)
        oauth.authorize(withCallbackURL: "PhotoNetwork://oauth-callback/flickr", completionHandler: {result in
            switch result {
            case .success(let response):
                let string = response.response?.dataString()
                let arrayString = string?.components(separatedBy: "&")
                let croppedString = arrayString?[3]
                let id = croppedString![String.Index(utf16Offset: 10, in: croppedString!)...]
                
                oauth.client.get("https://www.flickr.com/services/rest/", parameters: [
                    "api_key": "\(response.credential.consumerKey)",
                    "method": "flickr.photos.search",
                    "format": "json",
                    "nojsoncallback" : "1",
                    "extras": "url_o",
                    "user_id": "me"
                ], completionHandler: {result in
                    switch result {
                    case .success(let response):
                        let jsonObject = try? response.jsonObject()
                        print(jsonObject as Any)
                    case .failure(let error):
                        print(error.description)
                    }
                })
            case .failure(let error):
                print("error: \(error.description)")
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
