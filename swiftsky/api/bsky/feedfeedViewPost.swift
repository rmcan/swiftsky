//
//  feedfeedViewPost.swift
//  swiftsky
//

struct FeedFeedViewPostReplyRef: Decodable, Hashable {
    let parent: FeedPostView
    let root: FeedPostView
}

struct FeedFeedViewPost: Decodable, Hashable {
    var post: FeedPostView
    //let reason: FeedFeedViewPostReason?
    let reply: FeedFeedViewPostReplyRef?
}

