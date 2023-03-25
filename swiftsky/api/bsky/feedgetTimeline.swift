//
//  feedgetTimeline.swift
//  swiftsky
//

import Foundation

struct FeedGetTimelineInput: Encodable {
  let algorithm: String = "reverse-chronological"
  let limit: Int = 30
  let before: String?
}
struct FeedGetTimelineOutput: Decodable, Hashable, Identifiable {
  public static func == (lhs: FeedGetTimelineOutput, rhs: FeedGetTimelineOutput) -> Bool {
    return lhs.id == rhs.id
  }
  public var id: UUID {
    UUID()
  }
  var cursor: String? = ""
  var feed: [FeedFeedViewPost] = []
}

func getTimeline(before: String? = nil) async throws -> FeedGetTimelineOutput {
  return try await NetworkManager.shared.fetch(
    endpoint: "app.bsky.feed.getTimeline", authorization: NetworkManager.shared.user.accessJwt,
    params: FeedGetTimelineInput(before: before))
}
