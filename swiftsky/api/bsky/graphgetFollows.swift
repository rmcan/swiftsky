//
//  graphgetFollows.swift
//  swiftsky
//

struct graphGetFollowsInput: Encodable {
  let before: String?
  let limit: Int
  let user: String
}

struct graphGetFollowsOutput: Decodable {
  var cursor: String?
  var follows: [ActorRefWithInfo]
  let subject: ActorRefWithInfo
}

func graphGetFollows(user: String, limit: Int = 30, before: String? = nil) async throws -> graphGetFollowsOutput {
  return try await NetworkManager.shared.fetch(
    endpoint: "app.bsky.graph.getFollows", authorization: NetworkManager.shared.user.accessJwt,
    params: graphGetFollowsInput(before: before, limit: limit, user: user))
}
