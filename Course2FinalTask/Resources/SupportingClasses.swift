//
//  SupportingClasses.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 13.09.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import Foundation
import MastodonKit

class MutableAccount {
    /// The ID of the account.
    var id: String
    /// The username of the account.
    var username: String
    /// Equals username for local users, includes @domain for remote ones.
    var acct: String
    /// The account's display name.
    var displayName: String
    /// Biography of user.
    var note: String
    /// URL of the user's profile page (can be remote).
    var url: String
    /// URL to the avatar image.
    var avatar: String
    /// URL to the avatar static image
    var avatarStatic: String
    /// URL to the header image.
    var header: String
    /// URL to the header static image
    var headerStatic: String
    /// Boolean for when the account cannot be followed without waiting for approval first.
    var locked: Bool
    /// The time the account was created.
    var createdAt: Date
    /// The number of followers for the account.
    var followersCount: Int
    /// The number of accounts the given account is following.
    var followingCount: Int
    /// The number of statuses the account has made.
    var statusesCount: Int
    
    init(_ account: Account) {
        id = account.id
        username = account.username
        acct = account.acct
        displayName = account.displayName
        note = account.note
        url = account.url
        avatar = account.avatar
        avatarStatic = account.avatarStatic
        header = account.header
        headerStatic = account.headerStatic
        locked = account.locked
        createdAt = account.createdAt
        followersCount = account.followersCount
        followingCount = account.followingCount
        statusesCount = account.statusesCount
    }
}

class MutableStatus {
    /// The ID of the status.
    var id: String
    /// A Fediverse-unique resource ID.
    var uri: String
    /// URL to the status page (can be remote).
    var url: URL?
    /// The Account which posted the status.
    var account: Account
    /// null or the ID of the status it replies to.
    var inReplyToID: String?
    /// null or the ID of the account it replies to.
    var inReplyToAccountID: String?
    /// Body of the status; this will contain HTML (remote HTML already sanitized).
    var content: String
    /// The time the status was created.
    var createdAt: Date
    /// An array of Emoji.
    var emojis: [Emoji]
    /// The number of reblogs for the status.
    var reblogsCount: Int
    /// The number of favourites for the status.
    var favouritesCount: Int
    /// Whether the authenticated user has reblogged the status.
    var reblogged: Bool?
    /// Whether the authenticated user has favourited the status.
    var favourited: Bool?
    /// Whether media attachments should be hidden by default.
    var sensitive: Bool?
    /// If not empty, warning text that should be displayed before the actual content.
    var spoilerText: String
    /// The visibility of the status.
    var visibility: Visibility
    /// An array of attachments.
    var mediaAttachments: [Attachment]
    /// An array of mentions.
    var mentions: [Mention]
    /// An array of tags.
    var tags: [Tag]
    /// Application from which the status was posted.
    var application: Application?
    /// The detected language for the status.
    var language: String?
    /// The reblogged Status
    var reblog: Status?
    /// Whether this is the pinned status for the account that posted it.
    var pinned: Bool?
    init(_ status: Status) {
        id = status.id
        uri = status.uri
        url = status.url
        account = status.account
        inReplyToID = status.inReplyToID
        inReplyToAccountID = status.inReplyToAccountID
        content = status.content
        createdAt = status.createdAt
        emojis = status.emojis
        reblogsCount = status.reblogsCount
        favouritesCount = status.favouritesCount
        reblogged = status.reblogged
        favourited = status.favourited
        sensitive = status.sensitive
        spoilerText = status.spoilerText
        visibility = status.visibility
        mediaAttachments = status.mediaAttachments
        mentions = status.mentions
        tags = status.tags
        application = status.application
        language = status.language
        reblog = status.reblog
        pinned = status.pinned
    }
}
