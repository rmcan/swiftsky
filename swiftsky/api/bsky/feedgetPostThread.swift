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

public struct FeedGetPostThreadOutput: Decodable, Hashable {
    let thread: FeedGetPostThreadThreadViewPost?
}

public func getPostThread(uri: String, completion: @escaping (FeedGetPostThreadOutput?)->()) {
    api.shared.GET(endpoint: "app.bsky.feed.getPostThread",params: ["uri": uri], objectType: FeedGetPostThreadOutput.self, authorization: api.shared.user.accessJwt) { result in
        switch result {
        case .success(let result):
            completion(result)
        case .failure(let error):
            print(error)
            completion(nil)
        }
    }
}
