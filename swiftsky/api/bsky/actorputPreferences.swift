//
//  actorputPreferences.swift
//  swiftsky
//

struct ActorPutPreferencesInput: Encodable {
  let preferences: [ActorDefsPreferencesElem]
}

func ActorPutPreferences(input: [ActorDefsPreferencesElem]) async throws -> Bool {
  return try await Client.shared.fetch(
    endpoint: "app.bsky.actor.putPreferences", httpMethod: .post, authorization: Client.shared.user.accessJwt,
    params: ActorPutPreferencesInput(preferences: input))
}
