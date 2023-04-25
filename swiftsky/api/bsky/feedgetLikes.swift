//
//  feedgetLikes.swift
//  swiftsky
//

import Foundation

struct FeedGetLikesLike: Decodable, Identifiable {
  let id = UUID()
  let actor: ActorDefsProfileView
  let createdAt: String
  let indexedAt: String
  enum CodingKeys: CodingKey {
    case actor
    case createdAt
    case indexedAt
  }
}
struct feedgetLikesOutput: Decodable {
  let cid: String?
  var cursor: String?
  var likes: [FeedGetLikesLike]
  let uri: String
  init(cid: String? = nil, cursor: String? = nil, likes: [FeedGetLikesLike] = [], uri: String = "") {
    self.cid = cid
    self.cursor = cursor
    self.likes = likes
    self.uri = uri
  }
}
func feedgetLikes(cid: String, cursor: String? = nil, limit: Int = 30, uri: String) async throws -> feedgetLikesOutput {
  return try await NetworkManager.shared.fetch(
    endpoint: "app.bsky.feed.getLikes", authorization: NetworkManager.shared.user.accessJwt,
    params: ["cid" : cid, "cursor" : cursor, "limit": "\(limit)", "uri": uri].compactMapValues{$0})
}
