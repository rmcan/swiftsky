//
//  getPopularFeedGenerators.swift
//  swiftsky
//

struct getPopularFeedGeneratorsOutput: Decodable {
  let feeds: [FeedDefsGeneratorView]
}
func getPopularFeedGenerators() async throws -> getPopularFeedGeneratorsOutput {
  return try await Client.shared.fetch(
    endpoint: "app.bsky.unspecced.getPopularFeedGenerators", authorization: Client.shared.user.accessJwt,
    params: Optional<Bool>.none)
}
