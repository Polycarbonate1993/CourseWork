//
//  Model.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 26.06.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import MastodonKit

class User: Codable, DecodedJSONData {
    var id: String!
    var username: String!
    var fullName: String!
    var avatar: String!
    var currentUserFollowsThisUser: Bool!
    var currentUserIsFollowedByThisUser: Bool!
    var followsCount: Int!
    var followedByCount: Int!
}

class Post: Codable, DecodedJSONData {
    var author: String!
    var authorAvatar: String!
    var id: String!
    var likedByCount: Int!
    var image: String!
    var createdTime: String!
    var description: String?
    var authorUsername: String!
    var currentUserLikesThisPost: Bool = false
    
    /**Convertes date format from JSON date format to suitable.*/
    func dateFormattingFromJSON() -> String {
        let dateFrom = DateFormatter()
        let dateTo = DateFormatter()
        dateFrom.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateTo.dateStyle = .long
        dateTo.timeStyle = .medium
        dateTo.doesRelativeDateFormatting = true
        let date = dateFrom.date(from: createdTime) ?? Date()
        let newStringDate = dateTo.string(from: date)
        return newStringDate
    }
    
    init(fromStatus status: Status) {
        author = status.account.displayName
        authorAvatar = status.account.avatarStatic
        id = status.id
        likedByCount = status.favouritesCount
        image = status.mediaAttachments[0].previewURL
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true
        createdTime = dateFormatter.string(from: status.createdAt)
        description = try? NSAttributedString(data: status.content.data(using: .utf8)!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil).string
        authorUsername = status.account.username
        currentUserLikesThisPost = status.favourited!
    }
    
    init() {}
}
