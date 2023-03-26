//
//  graphgetFollowers.swift
//  swiftsky
//

struct graphGetFollowersInput: Encodable {
  let before: String?
  let limit: Int
  let user: String
}

struct graphGetFollowersOutput: Decodable {
  var cursor: String?
  var followers: [ActorRefWithInfo]
  let subject: ActorRefWithInfo
}

func graphGetFollowers(user: String, limit: Int = 30, before: String? = nil) async throws -> graphGetFollowersOutput {
  return try await NetworkManager.shared.fetch(
    endpoint: "app.bsky.graph.getFollowers", authorization: NetworkManager.shared.user.accessJwt,
    params: graphGetFollowersInput(before: before, limit: limit, user: user))
}
