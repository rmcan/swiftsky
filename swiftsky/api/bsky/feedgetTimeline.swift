//
//  feedgetTimeline.swift
//  swiftsky
//

import Foundation

public struct FeedGetTimelineOutput: Decodable, Hashable, Identifiable {
    public static func == (lhs: FeedGetTimelineOutput, rhs: FeedGetTimelineOutput) -> Bool {
        return lhs.id == rhs.id
    }
    public var id: UUID {
        UUID()
    }
    var cursor: String? = ""
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
