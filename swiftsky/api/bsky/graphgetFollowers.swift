//
//  graphgetFollowers.swift
//  swiftsky
//

struct graphGetFollowersInput: Encodable {
  let cursor: String?
  let limit: Int
  let actor: String
}

struct graphGetFollowersOutput: Decodable {
  var cursor: String?
  var followers: [ActorDefsProfileViewBasic]
  let subject: ActorDefsProfileViewBasic
}

func graphGetFollowers(actor: String, limit: Int = 30, cursor: String? = nil) async throws -> graphGetFollowersOutput {
  return try await NetworkManager.shared.fetch(
    endpoint: "app.bsky.graph.getFollowers", authorization: NetworkManager.shared.user.accessJwt,
    params: graphGetFollowersInput(cursor: cursor, limit: limit, actor: actor))
}
