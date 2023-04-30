//
//  feedgetAuthorFeed.swift
//  swiftsky
//

import Foundation

struct FeedGetAuthorFeedInput: Encodable {
  let actor: String
  let limit: Int = 100
  let cursor: String?
}

struct FeedGetAuthorFeedOutput: Decodable, Identifiable {
  let id = UUID()
  var cursor: String? = ""
  var feed: [FeedDefsFeedViewPost] = []
  enum CodingKeys: CodingKey {
    case cursor
    case feed
  }
}

func getAuthorFeed(actor: String, cursor: String? = nil) async throws
  -> FeedGetAuthorFeedOutput
{
  return try await Client.shared.fetch(
    endpoint: "app.bsky.feed.getAuthorFeed", authorization: Client.shared.user.accessJwt,
    params: FeedGetAuthorFeedInput(actor: actor, cursor: cursor))
}
