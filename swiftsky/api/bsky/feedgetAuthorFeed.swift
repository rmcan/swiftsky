//
//  feedgetAuthorFeed.swift
//  swiftsky
//

import Foundation

struct FeedGetAuthorFeedInput: Encodable {
    let author: String
    let limit: Int = 30
    let before: String?
}

public struct FeedGetAuthorFeedOutput: Decodable, Hashable, Identifiable {
    public var id: UUID {
        UUID()
    }
    var cursor: String? = ""
    var feed: [FeedFeedViewPost] = []
}

public func getAuthorFeed(author: String, before: String? = nil) async throws -> FeedGetAuthorFeedOutput {
    return try await NetworkManager.shared.fetch(endpoint: "app.bsky.feed.getAuthorFeed",authorization: NetworkManager.shared.user.accessJwt, params: FeedGetAuthorFeedInput(author: author, before: before))
}
