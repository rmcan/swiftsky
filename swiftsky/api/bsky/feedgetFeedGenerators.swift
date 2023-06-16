//
//  feedgetFeedGenerators.swift
//  swiftsky
//

struct FeedGetFeedGeneratorsOutput: Decodable {
  let feeds: [FeedDefsGeneratorView]
}
func FeedGetFeedGenerators(feeds: [String]) async throws -> FeedGetFeedGeneratorsOutput {
  return try await Client.shared.fetch(
    endpoint: "app.bsky.feed.getFeedGenerators", authorization: Client.shared.user.accessJwt,
    params: ["feeds[]": feeds])
}
