//
//  feedgetFeed.swift
//  swiftsky
//

struct FeedGetFeedOutput: Decodable {
  let feed: [FeedDefsFeedViewPost]
  let cursor: String?
}
struct FeedGetFeedInput: Encodable {
  let feed: String
  let cursor: String?
  let limit: Int?
}
func FeedGetFeed(feed: String, cursor: String? = nil, limit: Int? = nil) async throws -> FeedGetFeedOutput {
  return try await Client.shared.fetch(
    endpoint: "app.bsky.feed.getFeed", authorization: Client.shared.user.accessJwt,
    params: FeedGetFeedInput(feed: feed, cursor: cursor, limit: limit))
}
