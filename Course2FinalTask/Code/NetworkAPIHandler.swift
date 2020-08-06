//
//  NetworkAPIHandler.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 26.06.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import UIKit

/// A Class that hadndles all API methodes and transform them into easy to use Swift methods.
///
/// - Note:
/// You simply create an instance of this class like this:
///
/// ```
/// let apiHandler = APIHandler()
/// ```
///
class APIHandler {
    
    /// An authorization token that application gets when authorizes on the server.
    static var token: String?
    /// The property that stores the ID of logged user.
    static var currentUserId: String?
    /// Host
    static var server = "http://localhost:8080"
    /// The delegate that handles showing error alerts.
    var delegate: UIViewController?
    /// An offline mode indicator.
    static var offlineMode = false
    
    /// Authorizes user on a server.
    ///
    /// - Note:
    /// There is an example of usage:
    ///
    /// ```
    /// let apiHandler = APIHandler()
    /// apiHandler.signin(username: "user", password: "qwerty", completionHandler: {
    ///     // Some code to execute
    /// })
    /// ```
    ///
    /// - Parameters:
    ///   - username: User's username in `String`.
    ///   - password: User's password in `String`.
    ///   - completionHandler: Optional block of code that will be executed after you get the response from the server.
    /// - Returns: This method doesn't return anything.
    ///
    func signin(username: String, password: String, completionHandler: (() -> Void)? ) {
        var request = URLRequest(url: URL(string: APIHandler.server + "/signin")!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let stringData = "{\"login\":\"\(username)\",\"password\":\"\(password)\"}"
        request.httpBody = stringData.data(using: .utf8)
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                APIHandler.offlineMode = true
                DispatchQueue.main.async {
                    let newVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
                    NotificationCenter.default.removeObserver(self.delegate as Any)
                    newVC.dataManager = CoreDataManager(modelName: "Model")
                    UIApplication.shared.delegate?.window??.rootViewController = newVC
                    self.delegate?.generateAlert(title: "Offline Mode", message: "Functionality is limited.", buttonTitle: "OK")
                }
                return
            } else {
                APIHandler.offlineMode = false
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print(httpResponse.statusCode)
                    print(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
                    self.delegate?.generateAlert(title: "\(httpResponse.statusCode)", message: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode), buttonTitle: "OK")
                    return
                }
                guard let data = data else {
                    self.delegate?.generateAlert(title: "Oops!", message: "Something wrong with data.", buttonTitle: "OK")
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
                    completionHandler?()
                })
            }
        }
        dataTask.resume()
    }
    
    /// Signs out and invalidates token.
    ///
    /// - Note:
    /// This method mustn't be called before `signin(username:password:completionHandler:)`.
    /// There is an example of usage:
    ///
    /// ```
    /// let apiHandler = APIHandler()
    /// apiHandler.signout(completionHandler: {
    ///     // Some code to execute
    /// })
    /// ```
    ///
    /// - Parameters:
    ///   - completionHandler: Optional block of code that will be executed after signing out and token invalidation.
    /// - Returns: This method doesn't return anything.
    ///
    func signout(completionHandler: (() -> Void)? = nil) {
        var request = URLRequest(url: URL(string: APIHandler.server + "/signout")!)
        request.addValue(APIHandler.token ?? "", forHTTPHeaderField: "token")
        request.httpMethod = "POST"
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                APIHandler.offlineMode = true
                self.delegate?.generateAlert(title: "Offline Mode", message: "Functionality is limited", buttonTitle: "OK")
                    return
            }
            APIHandler.offlineMode = false
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print(httpResponse.statusCode)
                    print(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))
                    self.delegate?.generateAlert(title: "\(httpResponse.statusCode)", message: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode), buttonTitle: "OK")
                    return
                }
            }
            APIHandler.token = nil
            completionHandler?()
        }
        dataTask.resume()
    }
    
    enum CaseSwitcher {
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
    
    enum CheckTokenResult {
        case valid
        case invalid
        case offlineMode
    }
    
    /// Gets specified data for specified scenario.
    ///
    /// - Note:
    /// That is the main method in `APIHandler` class. You use it when you need to create URL query to the server and get data from it.
    /// Fro example you want to get user with specified ID from the server:
    ///
    /// ```
    /// let apiHandler = APIHandler()
    /// apiHandler.get(.user, withID: "2", completionHandler: {user in
    ///     guard let newUser = user as? User else {
    ///         // Some code to execute
    ///         return
    ///     }
    ///     // Some code to execute
    /// })
    /// ```
    ///
    /// Or if you need to get the current user you can do it simply as:
    ///
    /// ```
    /// let apiHandler = APIHandler()
    /// apiHandler.get(.user, completionHandler: {user in
    ///     guard let newUser = user as? User else {
    ///         // Some code to execute
    ///         return
    ///     }
    ///     // Some code to execute
    /// })
    /// ```
    ///
    /// - Parameters:
    ///   - scenario: An instance of `APIHandler.CaseSwitcher` enum. You use this parameter to determine wich result you want to get.
    ///   - id: ID of a user or a post. It depends on the scenario you choose.
    ///   - completionHandler: Optional block of code that will be executed after this method receives a response from the server.
    /// - Returns: This method returns data from the server into `completionHandler`.
    ///
    func get(_ scenario: CaseSwitcher, withID id: String? = nil, completionHandler: ((DecodedJSONData?) -> Void)? = nil) {
        if APIHandler.offlineMode {
            let dataManager = (delegate?.tabBarController as? TabBarController)?.dataManager
            switch scenario {
            case .feed:
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "inFeed == TRUE")])
                let fetchedFeed = dataManager?.fetchData(for: CoreDataPost.self, predicate: predicate)
                let newFeed = fetchedFeed?.importFromCoreDataToJSON(Post.self)
                print("fetched feed count: \(fetchedFeed?.count ?? 0)\nnew feed count: \(newFeed?.count ?? 0)")
                completionHandler?(newFeed)
            case .user:
                if id == nil {
                    let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "isCurrentUser == TRUE")])
                    let fetchedUser = dataManager?.fetchData(for: CoreDataUser.self, predicate: predicate)
                    let newUser = fetchedUser?.importFromCoreDataToJSON(User.self)
                    completionHandler?(newUser?[0])
                } else {
                    delegate?.generateAlert(title: "Offline Mode", message: "Functionality is limited", buttonTitle: "OK")
                    break
                }
            case .userPosts:
                if id == APIHandler.currentUserId {
                    let fetchedPosts = dataManager?.fetchData(for: CoreDataPost.self, predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "author == \(id!)")]))
                    let newPosts = fetchedPosts?.importFromCoreDataToJSON(Post.self)
                    completionHandler?(newPosts)
                } else {
                    delegate?.generateAlert(title: "Offline Mode", message: "Functionality is limited", buttonTitle: "OK")
                    break
                }
            default:
                delegate?.generateAlert(title: "Offline Mode", message: "Functionality is limited", buttonTitle: "OK")
                break
            }
        } else {
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
                    APIHandler.offlineMode = true
                    self.delegate?.generateAlert(title: "Offline Mode", message: "Functionality is limited", buttonTitle: "OK")
                    return
                }
                APIHandler.offlineMode = false
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
    }
    
    /// This method creates a post from given image and description.
    ///
    /// You use this method when you want to create a post and upload it to the server.
    ///
    /// - Note:
    /// You can use this method only with non-empty `UIImage` or you will get an error.
    /// Fro example:
    ///
    /// ```
    /// let apiHandler = APIHandler()
    /// let somePicture = UIImage(named: "item1")!
    /// let description = "What a cute doggo!!!"
    /// apiHandler.createPost(image: somePicture, description: description, completionHandler: {
    ///     // Some code to execute
    /// })
    /// ```
    ///
    /// - Parameters:
    ///   - image: Image that you want to be posted on the server.
    ///   - description: An optional comment to your post.
    ///   - completionHandler: An optional block of code that will be executed after the server responses.
    /// - Returns: This method doesn't return anything.
    ///
    func createPost(image: UIImage, description: String?, completionHandler: ((Post?) -> Void)? = nil) {
        if APIHandler.offlineMode {
            
        } else {
            let jpegData = image.jpegData(compressionQuality: 1)
            let stringJpeg = jpegData?.base64EncodedString()
            print(stringJpeg)
            let requestString = "{\"image\":\"\(stringJpeg ?? "")\",\"description\":\"\(description ?? "")\"}"
            let body = requestString.data(using: .utf8)
            var request = URLRequest(url: URL(string: APIHandler.server + "/posts/create")!)
            request.addValue(APIHandler.token ?? "", forHTTPHeaderField: "token")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
            request.httpMethod = "POST"
            let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else {
                    APIHandler.offlineMode = true
                    self.delegate?.generateAlert(title: "Offline Mode", message: "Functionality is limited", buttonTitle: "OK")
                    return
                }
                APIHandler.offlineMode = false
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        self.delegate?.generateAlert(title: "\(httpResponse.statusCode)", message: HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode), buttonTitle: "OKs")
                        return
                    }
                }
                guard let data = data else {
                    self.delegate?.generateAlert(title: "Oops!", message: "Something wrong with data.", buttonTitle: "OK")
                    return
                }
                let post = try? JSONDecoder().decode(Post.self, from: data)
                completionHandler?(post)
            }
            dataTask.resume()
        }
        
    }
    
    func checkToken(_ token: String?, completionHandler: ((CheckTokenResult) -> Void)? = nil){
        var request = URLRequest(url: URL(string: APIHandler.server + "/checkToken")!)
        request.addValue(token ?? "", forHTTPHeaderField: "token")
        request.httpMethod = "GET"
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                APIHandler.offlineMode = true
                completionHandler?(.offlineMode)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    APIHandler.offlineMode = false
                    completionHandler?(.valid)
                case 401:
                    APIHandler.offlineMode = false
                    completionHandler?(.invalid)
                default:
                    APIHandler.offlineMode = true
                    completionHandler?(.offlineMode)
                }
            }
        }
        dataTask.resume()
    }
}

protocol DecodedJSONData {}

extension Array: DecodedJSONData {}
