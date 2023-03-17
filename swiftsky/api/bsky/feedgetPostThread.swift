//
//  feedgetPostThread.swift
//  swiftsky
//

struct FeedGetPostThreadThreadViewPost: Decodable, Hashable {
    let post: FeedPostView
    //let parent: FeedGetPostThreadThreadViewPost?
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
