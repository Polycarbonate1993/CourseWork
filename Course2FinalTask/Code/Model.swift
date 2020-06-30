//
//  Model.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 26.06.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation

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
    var currentUserLikesThisPost: Bool!
    
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
}
