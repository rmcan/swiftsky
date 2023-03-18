//
//  feedfeedViewPost.swift
//  swiftsky
//

struct FeedFeedViewPostReplyRef: Decodable, Hashable {
    let parent: FeedPostView
    let root: FeedPostView
}
struct FeedFeedViewPostReason: Decodable, Hashable {
    let by: ActorRefWithInfo
    let indexedAt: String
}
struct FeedFeedViewPost: Decodable, Hashable {
    var post: FeedPostView
    let reason: FeedFeedViewPostReason?
    let reply: FeedFeedViewPostReplyRef?
}

