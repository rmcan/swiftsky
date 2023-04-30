//
//  feedgetTimeline.swift
//  swiftsky
//

import Foundation

struct FeedGetTimelineInput: Encodable {
  let algorithm: String = "reverse-chronological"
  let limit: Int = 30
  let cursor: String?
}
struct FeedGetTimelineOutput: Decodable, Identifiable {
  static func == (lhs: FeedGetTimelineOutput, rhs: FeedGetTimelineOutput) -> Bool {
    return lhs.id == rhs.id
  }
  let id = UUID()
  var cursor: String? = ""
  var feed: [FeedDefsFeedViewPost] = []
  enum CodingKeys: CodingKey {
    case cursor
    case feed
  }
}

func getTimeline(cursor: String? = nil) async throws -> FeedGetTimelineOutput {
  return try await Client.shared.fetch(
    endpoint: "app.bsky.feed.getTimeline", authorization: Client.shared.user.accessJwt,
    params: FeedGetTimelineInput(cursor: cursor))
}
