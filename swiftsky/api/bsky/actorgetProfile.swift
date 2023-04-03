//
//  actorprofile.swift
//  swiftsky
//

struct getProfileInput: Encodable {
  let actor: String
}

func actorgetProfile(actor: String) async throws -> ActorDefsProfileViewDetailed {
  return try await NetworkManager.shared.fetch(
    endpoint: "app.bsky.actor.getProfile", authorization: NetworkManager.shared.user.accessJwt,
    params: getProfileInput(actor: actor))
}
