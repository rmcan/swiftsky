//
//  feedsetVote.swift
//  swiftsky
//


struct FeedSetVoteInput: Encodable {
    let direction: String
    let subject: RepoStrongRef
}
public struct FeedSetVoteOutput: Decodable, Hashable {
    let downvote: String?
    let upvote: String?
}

func FeedSetVote(uri: String, cid: String, direction: String) async throws -> FeedSetVoteOutput {
    return try await NetworkManager.shared.fetch(endpoint: "app.bsky.feed.setVote", httpMethod: .POST, authorization: NetworkManager.shared.user.accessJwt, params: FeedSetVoteInput(direction: direction, subject: RepoStrongRef(cid: cid, uri: uri)))
}
