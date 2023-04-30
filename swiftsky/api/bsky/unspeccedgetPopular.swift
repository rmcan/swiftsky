//
//  unspeccedgetPopular.swift
//  swiftsky
//

import Foundation

struct UnspeccedGetPopularInput: Encodable {
  let limit: Int
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

func getPopular(cursor: String? = nil, limit: Int = 100) async throws -> UnspeccedGetPopularOutput {
  return try await Client.shared.fetch(
    endpoint: "app.bsky.unspecced.getPopular", authorization: Client.shared.user.accessJwt,
    params: UnspeccedGetPopularInput(limit: limit, cursor: cursor))
}
