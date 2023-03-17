//
//  feedpost.swift
//  swiftsky
//

import Foundation

struct RepoStrongRef: Decodable, Hashable {
    let cid: String
    let uri: String
}

struct FeedPostReplyRef: Decodable, Hashable {
    let parent: RepoStrongRef
    let root: RepoStrongRef
}

struct FeedPostTextSlice: Decodable, Hashable {
    let end: Int
    let start: Int
}

struct FeedPostEntity: Decodable, Hashable {
    let index: FeedPostTextSlice
    let type: String
    let value: String
}

struct FeedPost: Decodable, Hashable {
    let createdAt: Date
    let entities: [FeedPostEntity]?
    let reply: FeedPostReplyRef?
    let text: String
}

struct FeedPostViewerState: Decodable, Hashable {
    let downvote: String?
    let repost: String?
    var upvote: String?
}

struct FeedPostView: Decodable, Hashable {
    let author: ActorRefWithInfo
    var cid: String
    let downvoteCount: Int
    //let embed: FeedPostViewEmbed?
    let indexedAt: String
    let record: FeedPost
    let replyCount: Int
    let repostCount: Int
    var upvoteCount: Int
    let uri: String
    var viewer: FeedPostViewerState
}
