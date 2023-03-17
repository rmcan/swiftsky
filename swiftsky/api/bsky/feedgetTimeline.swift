//
//  feedgetTimeline.swift
//  swiftsky
//

public struct FeedGetTimelineOutput: Decodable, Hashable {
    var cursor: String? = nil
    var feed: [FeedFeedViewPost] = []
}

public func getTimeline(before: String? = nil, completion: @escaping (FeedGetTimelineOutput?)->()) {
    var params : [String : String] = ["algorithm" : "reverse-chronological", "limit": "30"]
    if let before = before {
        params["before"] = before
    }
    api.shared.GET(endpoint: "app.bsky.feed.getTimeline",params: params, objectType: FeedGetTimelineOutput.self, authorization: api.shared.user.accessJwt) { result in
        switch result {
        case .success(let result):
            completion(result)
        case .failure(let error):
            print(error)
            completion(nil)
        }
    }
}
