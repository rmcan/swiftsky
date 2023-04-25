//
//  feedgetPosts.swift
//  swiftsky
//

struct feedgetPostsOutput: Decodable {
  let posts: [FeedDefsPostView]
}
func feedgetPosts(uris: [String]) async throws -> feedgetPostsOutput {
  return try await NetworkManager.shared.fetch(
    endpoint: "app.bsky.feed.getPosts", authorization: NetworkManager.shared.user.accessJwt,
    params: ["uris[]": uris])
}
