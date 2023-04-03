//
//  feedgetPostThread.swift
//  swiftsky
//

import Foundation

class FeedGetPostThreadThreadViewPost: Decodable, Hashable, Identifiable {
  static func == (lhs: FeedGetPostThreadThreadViewPost, rhs: FeedGetPostThreadThreadViewPost)
    -> Bool
  {
    lhs.id == rhs.id
  }
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  let id = UUID()
  let type: String?
  let post: FeedDefsPostView?
  let parent: FeedGetPostThreadThreadViewPost?
  let replies: [FeedGetPostThreadThreadViewPost]?
  enum CodingKeys: CodingKey {
    case type
    case post
    case parent
    case replies
  }
}
struct FeedGetPostThreadInput: Encodable, Hashable {
  let uri: String
}
struct FeedGetPostThreadOutput: Decodable, Hashable {
  let thread: FeedGetPostThreadThreadViewPost?
}

func getPostThread(uri: String) async throws -> FeedGetPostThreadOutput {
  return try await NetworkManager.shared.fetch(
    endpoint: "app.bsky.feed.getPostThread", authorization: NetworkManager.shared.user.accessJwt,
    params: FeedGetPostThreadInput(uri: uri))
}
