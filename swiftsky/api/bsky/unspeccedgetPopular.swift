//
//  unspeccedgetPopular.swift
//  swiftsky
//

import Foundation

struct UnspeccedGetPopularInput: Encodable {
  let limit: Int = 30
  let cursor: String?
}

struct UnspeccedGetPopularOutput: Decodable, Identifiable {
  static func == (lhs: UnspeccedGetPopularOutput, rhs: UnspeccedGetPopularOutput) -> Bool {
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

func getPopular(cursor: String? = nil) async throws -> UnspeccedGetPopularOutput {
  return try await NetworkManager.shared.fetch(
    endpoint: "app.bsky.unspecced.getPopular", authorization: NetworkManager.shared.user.accessJwt,
    params: UnspeccedGetPopularInput(cursor: cursor))
}
