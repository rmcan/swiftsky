//
//  feedgetPostThread.swift
//  swiftsky
//

class FeedGetPostThreadThreadViewPost: Decodable, Hashable, Identifiable {
  static func == (lhs: FeedGetPostThreadThreadViewPost, rhs: FeedGetPostThreadThreadViewPost)
    -> Bool
  {
    lhs.post.cid == rhs.post.cid
  }
  func hash(into hasher: inout Hasher) {
    hasher.combine(post.cid)
  }
  let post: FeedDefsPostView
  let parent: FeedGetPostThreadThreadViewPost?
  let replies: [FeedGetPostThreadThreadViewPost]?
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
