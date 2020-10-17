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
import p2_OAuth2

class NewAPIHandler {
    
    static var client = Client(baseURL: "https://mstdn.social")
    static var server: String?
    static var currentUserID: String?
    static var clientID: String?
    static var clientSecret: String?
    var delegate: UIViewController?
    
    init(accessToken: String?, clientID: String?, clientSecret: String?, server: String, completionHandler: @escaping() -> Void) {
        NewAPIHandler.client = Client(baseURL: server, accessToken: accessToken, session: URLSession.shared)
        NewAPIHandler.server = server
        NewAPIHandler.clientID = clientID
        NewAPIHandler.clientSecret = clientSecret
        if NewAPIHandler.currentUserID == nil {
            let request = Accounts.currentUser()
            NewAPIHandler.client.run(request, completion: {result in
                switch result {
                case .success(let account, _):
                    NewAPIHandler.currentUserID = account.id
                    completionHandler()
                case .failure(let error):
                    print("init error")
                    self.delegate?.generateAlert(title: "Oops!", message: error.asOAuth2Error.description, buttonTitle: "Try Again Later")
                }
            })
        } else {
            completionHandler()
        }
    }
    
    init() {}
    
    func logOut(_ completion: (() -> Void)? = nil) {
        let parameters = [
            [
                "key": "client_id",
                "value": "\(NewAPIHandler.clientID!)",
                "type": "String"
            ],
            [
                "key": "client_secret",
                "value": "\(NewAPIHandler.clientSecret!)",
                "type": "String"
            ],
            [
                "key": "token",
                "value": "\(NewAPIHandler.client.accessToken!)",
                "type": "String"
            ]
            ] as [[String : Any]]

        let boundary = "Boundary-\(UUID().uuidString)"
        var body = ""
        var _: Error? = nil
        for param in parameters {
            if param["disabled"] == nil {
                let paramName = param["key"]!
                body += "--\(boundary)\r\n"
                body += "Content-Disposition:form-data; name=\"\(paramName)\""
                let paramType = param["type"] as! String
                if paramType == "String" {
                    let paramValue = param["value"] as! String
                    body += "\r\n\r\n\(paramValue)\r\n"
                } else {
                    let paramSrc = param["src"] as! String
                    let fileData = try! NSData(contentsOfFile:paramSrc, options:[]) as Data
                    let fileContent = String(data: fileData, encoding: .utf8)!
                    body += "; filename=\"\(paramSrc)\"\r\n" + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"
                }
            }
        }
        body += "--\(boundary)--\r\n";
        let postData = body.data(using: .utf8)

        var request = URLRequest(url: URL(string: NewAPIHandler.server! + "/oauth/revoke")!,timeoutInterval: Double.infinity)
        request.addValue("Bearer \(NewAPIHandler.client.accessToken!)", forHTTPHeaderField: "Authorization")
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            completion?()
            print(request.url)
        }

        task.resume()
    }
    
    func getFeed(range: RequestRange = .limit(10), completionHandler: (([Status]?) -> Void)? = nil) {
        let request = Timelines.home(range: range)
        print("request path: \(request)")
        NewAPIHandler.client.run(request, completion: {result in
            switch result {
            case .success(let feed, _):
                completionHandler?(feed)
            case .failure(let error):
                completionHandler?(nil)
                print(error.localizedDescription)
                self.delegate?.generateAlert(title: "Oops!", message: error.localizedDescription, buttonTitle: "Try Again Later")
            }
        })
    }
    
    func getCurrentUserFeed(completionHandler: @escaping(([Status]) -> Void)) {
        let request = Accounts.statuses(id: NewAPIHandler.currentUserID!)
        NewAPIHandler.client.run(request, completion: {result in
            switch result {
            case .success(let feed, _):
                completionHandler(feed)
            case .failure(let error):
                print(error.localizedDescription)
                self.delegate?.generateAlert(title: "Oops!", message: error.localizedDescription, buttonTitle: "Try Again Later")
            }
        })
    }
    
    func getUser(withID id: String, completionHandler: @escaping((Account?) -> Void)) {
        let request = Accounts.account(id: id)
        NewAPIHandler.client.run(request, completion: {result in
            switch result {
            case .success(let account, _):
                completionHandler(account)
            case .failure(let error):
                completionHandler(nil)
                self.delegate?.generateAlert(title: "Oops!", message: error.asOAuth2Error.description, buttonTitle: "Try Again Later")
            }
        })
    }
    
    func getUserPosts(withID id: String, onlyMedia: Bool, range: RequestRange, completionHandler: @escaping(([Status]?) -> Void)) {
        let request = Accounts.statuses(id: id, mediaOnly: onlyMedia, pinnedOnly: false, excludeReplies: true, range: range)
        NewAPIHandler.client.run(request, completion: {result in
            switch result {
            case .success(let statuses, _):
                completionHandler(statuses)
            case .failure(let error):
                completionHandler(nil)
                self.delegate?.generateAlert(title: "Oops!", message: error.asOAuth2Error.description, buttonTitle: "Try Again Later")
            }
        })
    }
    
    func getUsers(_ retrievingCase: UsersTableViewController.RetrievingCase, withID id: String?, completionHandler: @escaping([Account]) -> Void) {
        var request: Request<[Account]>
        switch retrievingCase {
        case .followers:
            request = Accounts.followers(id: id ?? "", range: .limit(80))
        case .following:
            request = Accounts.following(id: id ?? "", range: .limit(80))
        case .likes(let id):
            request = Statuses.favouritedBy(id: id, range: .limit(80))
        }
        NewAPIHandler.client.run(request, completion: {result in
            switch result {
            case .success(let accounts, _):
                completionHandler(accounts)
            case .failure(let error):
                self.delegate?.generateAlert(title: "Oops!", message: error.asOAuth2Error.description, buttonTitle: "Try Again Later")
            }
        })
    }
    
    func post(text: String?, image: UIImage?, completion: (() -> Void)? = nil) {
        guard let image = image else {
            if let text = text {
                let request = Statuses.create(status: text)
                NewAPIHandler.client.run(request, completion: {result in
                    switch result {
                    case .success(_, _):
                        completion?()
                    case .failure(let error):
                        self.delegate?.generateAlert(title: "Oops!", message: error.localizedDescription, buttonTitle: "Try Again Later")
                    }
                })
            }
            return
        }
        let data = image.jpegData(compressionQuality: 1)
        let request = Media.upload(media: .jpeg(data))
        NewAPIHandler.client.run(request, completion: {result in
            switch result {
            case .success(let attachment, _):
                let request = Statuses.create(status: text ?? "", replyToID: nil, mediaIDs: [attachment.id], sensitive: nil, spoilerText: nil, visibility: .public)
                NewAPIHandler.client.run(request, completion: {result in
                    switch result {
                    case .success(_, _):
                        completion?()
                    case .failure(let error):
                        self.delegate?.generateAlert(title: "Oops!", message: error.localizedDescription, buttonTitle: "Try Again Later")
                    }
                })
            case .failure(let error):
                self.delegate?.generateAlert(title: "Oops!", message: error.localizedDescription, buttonTitle: "Try Again Later")
            }
        })
    }
    
    func like(postID: String, completion: ((Status?) -> Void)? = nil) {
        let request = Statuses.favourite(id: postID)
        NewAPIHandler.client.run(request, completion: {result in
            switch result {
            case .success(let status, _):
                completion?(status)
            case .failure(let error):
                completion?(nil)
                self.delegate?.generateAlert(title: "Oops!", message: error.localizedDescription, buttonTitle: "Try Again Later")
            }
        })
    }
    
    func unlike(postID: String, completion: ((Status?) -> Void)? = nil) {
        let request = Statuses.unfavourite(id: postID)
        NewAPIHandler.client.run(request, completion: {result in
            switch result {
            case .success(let status, _):
                completion?(status)
            case .failure(let error):
                completion?(nil)
                self.delegate?.generateAlert(title: "Oops!", message: error.localizedDescription, buttonTitle: "Try Again Later")
            }
        })
    }
    
    func follow(id: String, _ completion: @escaping((Account?) -> Void)) {
        let request = Accounts.follow(id: id)
        NewAPIHandler.client.run(request, completion: {result in
            switch result {
            case .success(let account, _):
                completion(account)
            case .failure(_):
                completion(nil)
            }
        })
    }
    
    func unfollow(id: String, _ completion: @escaping((Account?) -> Void)) {
        let request = Accounts.unfollow(id: id)
        NewAPIHandler.client.run(request, completion: {result in
            switch result {
            case .success(let account, _):
                completion(account)
            case .failure(_):
                completion(nil)
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
