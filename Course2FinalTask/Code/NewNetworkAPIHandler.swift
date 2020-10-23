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
    
    static var client = Client(baseURL: "https://mstdn.social")
    static var server: String?
    static var currentUserID: String?
    static var clientID: String?
    static var clientSecret: String?
    var delegate: UIViewController?
    
    /// Initializes NewAPIHandler with given parameters.
    /// - Parameters:
    ///   - accessToken: Access token for making authorized requests through Mastodon API.
    ///   - clientID: Client ID of a registered application on Mastodon server.
    ///   - clientSecret: Client Secret of a registered application on Mastodon server.
    ///   - server: Mastodon server host.
    ///   - completionHandler: Block of code that will be executed after initialization.
    ///
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
                    self.delegate?.generateAlert(title: "Oops!", message: error.localizedDescription, buttonTitle: "Try Again Later")
                }
            })
        } else {
            completionHandler()
        }
    }
    
    /// Use This initializer after creating at least on instance of NewAPIHandler.
    init() {}
    
    
    
    /// Revokes access token.
    /// - Parameter completion: Block of code that will be executed after completion of the method.
    ///
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
            guard data != nil else {
                self.delegate?.generateAlert(title: "Oops!", message: error?.localizedDescription ?? "", buttonTitle: "Try Again Later")
                return
            }
            completion?()
        }
        task.resume()
    }
    
    /// Requests Home timeline for authorized user.
    /// - Parameters:
    ///   - range: Range for statuses. Can be set with limited amount of statuses and also starting or ending position.
    ///   - completionHandler: Block of code that will be executed after receiving a response from server. This block captures the result of the request: [Status]?.
    ///
    func getFeed(range: RequestRange = .limit(10), completionHandler: (([Status]?) -> Void)? = nil) {
        let request = Timelines.home(range: range)
        NewAPIHandler.client.run(request, completion: {result in
            switch result {
            case .success(let feed, _):
                completionHandler?(feed)
            case .failure(let error):
                completionHandler?(nil)
                self.delegate?.generateAlert(title: "Oops!", message: error.localizedDescription, buttonTitle: "Try Again Later")
            }
        })
    }
    
    /// Requests User with specified User ID.
    /// - Parameters:
    ///   - id: User ID
    ///   - completionHandler: Block of code that will be executed after receiving a response from server. This block captures the result of the request: Account?.
    ///
    func getUser(withID id: String, completionHandler: @escaping((Account?) -> Void)) {
        let request = Accounts.account(id: id)
        NewAPIHandler.client.run(request, completion: {result in
            switch result {
            case .success(let account, _):
                completionHandler(account)
            case .failure(let error):
                completionHandler(nil)
                self.delegate?.generateAlert(title: "Oops!", message: error.localizedDescription, buttonTitle: "Try Again Later")
            }
        })
    }
    
    /// Requests for statuses of specified User ID, media integration and range of statuses.
    /// - Parameters:
    ///   - id: User ID
    ///   - onlyMedia: If set true, the result of the request will contain only statuses with media attachments. if set false, the result of the request will contain all kinds of ststuses.
    ///   - range: Range for statuses. Can be set with limited amount of statuses and also starting or ending position.
    ///   - completionHandler: Block of code that will be executed after receiving a response from server. This block captures the result of the request: [Status]?.
    ///
    func getUserPosts(withID id: String, onlyMedia: Bool, range: RequestRange, completionHandler: @escaping(([Status]?) -> Void)) {
        let request = Accounts.statuses(id: id, mediaOnly: onlyMedia, pinnedOnly: false, excludeReplies: true, range: range)
        NewAPIHandler.client.run(request, completion: {result in
            switch result {
            case .success(let statuses, _):
                completionHandler(statuses)
            case .failure(let error):
                completionHandler(nil)
                self.delegate?.generateAlert(title: "Oops!", message: error.localizedDescription, buttonTitle: "Try Again Later")
            }
        })
    }
    
    /// Requests a list users with specified filter.
    /// - Parameters:
    ///   - retrievingCase: Special filter that determines which kind of users should be requested.
    ///   - range: Range for users. Can be set with limited amount of users and also starting or ending position.
    ///   - id: Either User ID or Status ID.
    ///   - completionHandler: Block of code that will be executed after receiving a response from server. This block captures the result of the request: [Account]?.
    ///
    func getUsers(_ retrievingCase: UsersTableViewController.RetrievingCase, range: RequestRange, withID id: String?, completionHandler: @escaping([Account]) -> Void) {
        var request: Request<[Account]>
        switch retrievingCase {
        case .followers:
            request = Accounts.followers(id: id ?? "", range: range)
        case .following:
            request = Accounts.following(id: id ?? "", range: range)
        case .likes(let id):
            request = Statuses.favouritedBy(id: id, range: range)
        }
        NewAPIHandler.client.run(request, completion: {result in
            switch result {
            case .success(let accounts, _):
                completionHandler(accounts)
            case .failure(let error):
                self.delegate?.generateAlert(title: "Oops!", message: error.localizedDescription, buttonTitle: "Try Again Later")
            }
        })
    }
    
    /// Posts your status on the server.
    /// - Parameters:
    ///   - text: The body of your status.
    ///   - image: Media attachment (image/photo) in jpeg representation.
    ///   - completion: Block of code that will be executed after receiving a response from server. This block will be executed in case of successful response from the server.
    ///
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
        var compressionQuality: CGFloat = 1
        guard var data = image.jpegData(compressionQuality: compressionQuality) else {
            self.delegate?.generateAlert(title: "Oops!", message: "Couldn't process jpeg data", buttonTitle: "Try Again Later")
            return
        }
        while (data as NSData).length > 8388608 {
            compressionQuality -= 0.01
            guard let compressed = image.jpegData(compressionQuality: compressionQuality) else {
                self.delegate?.generateAlert(title: "Oops!", message: "Couldn't process jpeg data", buttonTitle: "Try Again Later")
                return
            }
            data = compressed
        }
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
    
    /// Marks status as favorited by authorized user on server.
    /// - Parameters:
    ///   - postID: ID of the status that requested to be favourited.
    ///   - completion: Block of code that will be executed after receiving a response from server. This block captures the result of the request: Status?, which is the updated Status after being marked as favourited.
    ///
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
    
    /// Unmarks status as favourited by authorized user on server.
    /// - Parameters:
    ///   - postID: ID of the status the requested to be unmarked.
    ///   - completion: Block of code that will be executed after receiving a response from server. This block captures the result of the request: Status?, which is the updated Status after being unmarked as favourited.
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
    
    /// Marks user with specified ID as followed by authorized user.
    /// - Parameters:
    ///   - id: ID of the user needed to be marked.
    ///   - completion: Block of code that will be executed after receiving a response from server. This block captures the result of the request: Account?, which is the updated Account after being marked as followed.
    ///
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
    
    /// Unmarks user with specified ID as followed by authorized user.
    /// - Parameters:
    ///   - id: ID of the user needed to be unmarked.
    ///   - completion: Block of code that will be executed after receiving a response from server. This block captures the result of the request: Account?, which is the updated Account after being unmarked as followed.
    ///
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
}
