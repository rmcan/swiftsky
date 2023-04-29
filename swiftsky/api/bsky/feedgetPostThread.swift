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
  let notfound: Bool
  enum CodingKeys: CodingKey {
    case type
    case post
    case parent
    case replies
  }
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.type = try container.decodeIfPresent(String.self, forKey: .type)
    self.post = try container.decodeIfPresent(FeedDefsPostView.self, forKey: .post)
    self.parent = try container.decodeIfPresent(FeedGetPostThreadThreadViewPost.self, forKey: .parent)
    self.replies = try container.decodeIfPresent([FeedGetPostThreadThreadViewPost].self, forKey: .replies)
    self.notfound = self.type == "app.bsky.feed.defs#notFoundPost"
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
