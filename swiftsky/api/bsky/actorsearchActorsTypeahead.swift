//
//  actorsearchActorsTypeahead.swift
//  swiftsky
//

struct ActorSearchActorsTypeaheadOutput: Decodable {
  let actors: [ActorDefsProfileViewBasic]
  init(actors: [ActorDefsProfileViewBasic] = []) {
    self.actors = actors
  }
}
struct ActorSearchActorsTypeaheadInput: Encodable {
  let limit: Int
  let term: String
}
func ActorSearchActorsTypeahead(limit: Int = 10, term: String) async throws -> ActorSearchActorsTypeaheadOutput {
  return try await NetworkManager.shared.fetch(
    endpoint: "app.bsky.actor.searchActorsTypeahead", authorization: NetworkManager.shared.user.accessJwt,
    params: ActorSearchActorsTypeaheadInput(limit: limit, term: term))
}
