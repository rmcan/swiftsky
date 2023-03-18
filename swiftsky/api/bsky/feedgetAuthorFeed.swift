//
//  feedgetAuthorFeed.swift
//  swiftsky
//

public struct FeedGetAuthorFeedOutput: Decodable, Hashable {
    var cursor: String?
    var feed: [FeedFeedViewPost]
    init(cursor: String? = nil, feed: [FeedFeedViewPost] = []) {
        self.cursor = cursor
        self.feed = feed
    }
}

public func getAuthorFeed(author: String,before: String? = nil, completion: @escaping (FeedGetAuthorFeedOutput?)->()) {
    var params : [String : String] = ["author" : author, "limit": "30"]
    if let before = before {
        params["before"] = before
    }
    api.shared.GET(endpoint: "app.bsky.feed.getAuthorFeed",params: params, objectType: FeedGetAuthorFeedOutput.self, authorization: api.shared.user.accessJwt) { result in
        switch result {
        case .success(let result):
            completion(result)
        case .failure(let error):
            print(error)
            completion(nil)
        }
    }
}
