//
//  feedgetPostThread.swift
//  swiftsky
//

class FeedGetPostThreadThreadViewPost: Decodable, Hashable, Identifiable {
    static func == (lhs: FeedGetPostThreadThreadViewPost, rhs: FeedGetPostThreadThreadViewPost) -> Bool {
        lhs.post.cid == rhs.post.cid
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(post.cid)
    }
    let post: FeedPostView
    let parent: FeedGetPostThreadThreadViewPost?
    let replies: [FeedGetPostThreadThreadViewPost]?
}

struct FeedGetPostThreadOutput: Decodable, Hashable {
    let thread: FeedGetPostThreadThreadViewPost?
}

func getPostThread(uri: String, completion: @escaping (api.Result<FeedGetPostThreadOutput>)->()) {
    api.shared.GET(endpoint: "app.bsky.feed.getPostThread",params: ["uri": uri], objectType: FeedGetPostThreadOutput.self, authorization: api.shared.user.accessJwt) { result in
        completion(result)
    }
}
