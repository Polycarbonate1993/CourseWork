//
//  NewNetworkAPIHandler.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 19.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import MastodonKit
import UIKit

class NewAPIHandler {
    
    static private var client = Client(baseURL: "https://mstdn.social")
    static var currentUserID: String?
    var delegate: UIViewController?
    
    init(accessToken: String, completionHandler: @escaping() -> Void) {
        NewAPIHandler.client.accessToken = accessToken
        if NewAPIHandler.currentUserID == nil {
            let request = Accounts.currentUser()
            NewAPIHandler.client.run(request, completion: {result in
                switch result {
                case .success(let account, _):
                    NewAPIHandler.currentUserID = account.id
                    completionHandler()
                case .failure(let error):
                    print(4)
                    self.delegate?.generateAlert(title: "Oops!1", message: error.asOAuth2Error.description, buttonTitle: "Try Again Later")
                }
            })
        }
    }
    init() {
        
    }
    
    func getFeed(completionHandler: (([Status]) -> Void)? = nil) {
        let request = Timelines.home(range: .limit(40))
        NewAPIHandler.client.run(request, completion: {result in
            switch result {
            case .success(let feed, let pagination):
                for _ in 0...10 {
                    print("!")
                }
                print(feed.count)
                completionHandler?(feed)
            case .failure(let error):
                self.delegate?.generateAlert(title: "Oops!2", message: error.localizedDescription, buttonTitle: "Try Again Later")
            }
        })
    }
    
    func getCurrentUserFeed(completionHandler: @escaping(([Status]) -> Void)) {
        let request = Accounts.statuses(id: NewAPIHandler.currentUserID!)
        NewAPIHandler.client.run(request, completion: {result in
            switch result {
            case .success(let feed, _):
                for _ in 0...10 {
                    print("!")
                }
                print(feed.count)
                completionHandler(feed)
            case .failure(let error):
                self.delegate?.generateAlert(title: "Oops!2", message: error.localizedDescription, buttonTitle: "Try Again Later")
            }
        })
    }
    
    enum CaseSwitcher {
        case user
        case post
        case followers
        case following
        case userPosts
        case follow
        case unfollow
        case like
        case unlike
        case likes
    }
    
    enum CheckTokenResult {
        case valid
        case invalid
        case offlineMode
    }
}