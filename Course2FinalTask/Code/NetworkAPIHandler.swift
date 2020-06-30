//
//  NetworkAPIHandler.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 26.06.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit
class APIHandler {
    static var token: String?
    static var currentUserId: String?
    static var server = "http://localhost:8080"
    var delegate: UIViewController?
    
    
    func signin(username: String, password: String, completionHandler: (() -> Void)? ) {
        var request = URLRequest(url: URL(string: APIHandler.server + "/signin")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let stringData = "{\"login\":\"\(username)\",\"password\":\"\(password)\"}"
    
        request.httpBody = stringData.data(using: .utf8)
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                self.delegate?.generateAlert(title: error?.localizedDescription ?? "", message: error.debugDescription, buttonTitle: "OK")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print(httpResponse.statusCode)
                    print(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
                    self.delegate?.generateAlert(title: "\(httpResponse.statusCode)", message: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode), buttonTitle: "OK", activity: false)
                    return
                }
                
                guard let data = data else {
                    self.delegate?.generateAlert(title: "Oops!", message: "Something wrong with data.", buttonTitle: "OK", activity: false)
                    return
                }
                
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    self.delegate?.generateAlert(title: "Oops!", message: "Error trying to decode JSON.", buttonTitle: "OK")
                    return
                }
                guard let token = json["token"] as? String else {
                    self.delegate?.generateAlert(title: "Oops", message: "Something wrong with token.", buttonTitle: "OK")
                    return
                }
                APIHandler.token = token
                self.get(.user, withID: nil, completionHandler: {user in
                    guard let currentUser = user as? User else {
                        self.delegate?.generateAlert(title: "Oops!", message: "Error trying to decode JSON.", buttonTitle: "OK")
                        return
                    }
                    APIHandler.currentUserId = currentUser.id
                })
                completionHandler?()
                
            }
        }
        dataTask.resume()
    }
    
    func signout(completionHandler: (() -> Void)? = nil) {
        var request = URLRequest(url: URL(string: APIHandler.server + "/signout")!)
        request.addValue(APIHandler.token ?? "", forHTTPHeaderField: "token")
            request.httpMethod = "POST"
            
            let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    self.delegate?.generateAlert(title: error?.localizedDescription ?? "", message: error.debugDescription, buttonTitle: "OK")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        print(httpResponse.statusCode)
                        print(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
                        self.delegate?.generateAlert(title: "\(httpResponse.statusCode)", message: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode), buttonTitle: "OK", activity: false)
                        return
                    }
                }
                APIHandler.token = nil
                completionHandler?()
            }
            dataTask.resume()
    }
    
    enum caseSwitcher {
        case user
        case post
        case followers
        case following
        case userPosts
        case feed
        case follow
        case unfollow
        case like
        case unlike
        case likes
        
    }
    
    func get(_ scenario: caseSwitcher, withID id: String? = nil, completionHandler: ((DecodedJSONData?) -> Void)? = nil) {
        var request: URLRequest
        
        switch scenario {
        case .user:
            if id == nil {
                request = URLRequest(url: URL(string: APIHandler.server + "/users/me")!)
            } else {
                request = URLRequest(url: URL(string: APIHandler.server + "/users/\(id!)")!)
            }
        case .post:
            request = URLRequest(url: URL(string: APIHandler.server + "/posts/\(id ?? "")")!)
        case .followers, .following:
            if id == nil {
                if scenario == .followers {
                    request = URLRequest(url: URL(string: APIHandler.server + "/users/me/followers")!)
                } else {
                    request = URLRequest(url: URL(string: APIHandler.server + "/users/me/following")!)
                }
                
            } else {
                if scenario == .followers {
                    request = URLRequest(url: URL(string: APIHandler.server + "/users/\(id ?? "")/followers")!)
                } else {
                    request = URLRequest(url: URL(string: APIHandler.server + "/users/\(id ?? "")/following")!)
                }
            }
        case .userPosts:
            if id == nil {
                request = URLRequest(url: URL(string: APIHandler.server + "/users/\(APIHandler.currentUserId ?? "")/posts")!)
            } else {
                request = URLRequest(url: URL(string: APIHandler.server + "/users/\(id ?? "")/posts")!)
            }
        case .feed:
            request = URLRequest(url: URL(string: APIHandler.server + "/posts/feed")!)
        case .follow, .unfollow:
            if scenario == .follow {
                request = URLRequest(url: URL(string: APIHandler.server + "/users/follow")!)
            } else {
                request = URLRequest(url: URL(string: APIHandler.server + "/users/unfollow")!)
            }
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let bodyString = "{\"userID\":\"\(id ?? "")\"}"
            request.httpBody = bodyString.data(using: .utf8)
        case .like, .unlike:
            if scenario == .like {
                request = URLRequest(url: URL(string: APIHandler.server + "/posts/like")!)
            } else {
                request = URLRequest(url: URL(string: APIHandler.server + "/posts/unlike")!)
            }
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let bodyString = "{\"postID\":\"\(id ?? "")\"}"
            request.httpBody = bodyString.data(using: .utf8)
        case .likes:
            request = URLRequest(url: URL(string: APIHandler.server + "/posts/\(id ?? "")/likes")!)
            
            
        }
        
        request.addValue(APIHandler.token ?? "", forHTTPHeaderField: "token")
        let dataTask = URLSession.shared.dataTask(with: request) {data, response, error in
            guard error == nil else {
                self.delegate?.generateAlert(title: error?.localizedDescription ?? "", message: error.debugDescription, buttonTitle: "OK")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    self.delegate?.generateAlert(title: "\(httpResponse.statusCode)", message: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode), buttonTitle: "OK")
                    return
                }
            }
            guard let data = data else {
                self.delegate?.generateAlert(title: "Oops!", message: "Something wrong with data.", buttonTitle: "OK")
                return
            }
            switch scenario {
            case .user, .follow, .unfollow:
                let user = try? JSONDecoder().decode(User.self, from: data)
                completionHandler?(user)
            case .post, .like, .unlike:
                let post = try? JSONDecoder().decode(Post.self, from: data)
                completionHandler?(post)
            case .followers, .following, .likes:
                let users = try? JSONDecoder().decode([User].self, from: data)
                completionHandler?(users)
            case .userPosts, .feed:
                let posts = try? JSONDecoder().decode([Post].self, from: data)
                completionHandler?(posts)
            }
        }
        dataTask.resume()
    }
    
    func createPost(image: UIImage, description: String?, completionHandler: (() -> Void)? = nil) {
        let jpegData = image.jpegData(compressionQuality: 1)
        let stringJpeg = jpegData?.base64EncodedString()
        let requestString = "{\"image\":\"\(stringJpeg ?? "")\",\"description\":\"\(description ?? "")\"}"
//        print(requestString)
        let body = requestString.data(using: .utf8)
//        let afterBody = String(data: body!, encoding: .utf8)
//        print(afterBody!)
        var request = URLRequest(url: URL(string: APIHandler.server + "/posts/create")!)
        request.addValue(APIHandler.token ?? "", forHTTPHeaderField: "token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        request.httpMethod = "POST"
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                self.delegate?.generateAlert(title: error.debugDescription, message: error?.localizedDescription ?? "", buttonTitle: "OK")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    self.delegate?.generateAlert(title: "\(httpResponse.statusCode)", message: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode), buttonTitle: "OKs")
                    return
                }
            }
            guard data != nil else {
                self.delegate?.generateAlert(title: "Oops!", message: "Something wrong with data.", buttonTitle: "OK")
                return
            }
            
            completionHandler?()
        }
        dataTask.resume()
    }
}

protocol DecodedJSONData {}

extension Array: DecodedJSONData {}
