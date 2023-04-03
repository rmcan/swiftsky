//
//  repocreateRecord.swift
//  swiftsky
//

import Foundation

struct RepoCreateRecordOutput: Decodable {
  let cid: String
  let uri: String
}
struct LikePostInput: Encodable {
  let subject: RepoStrongRef
  let createdAt: String
}
struct FollowUserInput: Encodable {
  let subject: String
  let createdAt: String
}
struct CreatePostInput: Encodable {
  let text: String
  let createdAt: String
  let reply: FeedPostReplyRef?
}
struct RepoCreateRecordInput<T: Encodable>: Encodable {
  let type: String
  let collection: String
  let repo: String
  let record: T
  enum CodingKeys: String, CodingKey {
    case type = "$type"
    case collection
    case repo
    case record
  }
}

func repoCreateRecord<T: Encodable>(input: RepoCreateRecordInput<T>) async throws
  -> RepoCreateRecordOutput
{
  return try await NetworkManager.shared.fetch(
    endpoint: "com.atproto.repo.createRecord", httpMethod: .post,
    authorization: NetworkManager.shared.user.accessJwt, params: input)
}
func followUser(did: String) async throws -> RepoCreateRecordOutput {
  return try await repoCreateRecord(
    input: RepoCreateRecordInput(
      type: "app.bsky.graph.follow", collection: "app.bsky.graph.follow",
      repo: NetworkManager.shared.did,
      record: FollowUserInput(
        subject: did,
        createdAt: Date().iso8601withFractionalSeconds)))
}
func makePost(text: String, reply: FeedPostReplyRef? = nil) async throws -> RepoCreateRecordOutput {
  return try await repoCreateRecord(
    input: RepoCreateRecordInput(
      type: "app.bsky.feed.post", collection: "app.bsky.feed.post", repo: NetworkManager.shared.did,
      record: CreatePostInput(
        text: "test", createdAt: Date().iso8601withFractionalSeconds, reply: reply)))
}
func likePost(uri: String, cid: String) async throws -> RepoCreateRecordOutput {
  return try await repoCreateRecord(
    input: RepoCreateRecordInput(
      type: "app.bsky.feed.like", collection: "app.bsky.feed.like", repo: NetworkManager.shared.did,
      record: LikePostInput(
        subject: RepoStrongRef(cid: cid, uri: uri), createdAt: Date().iso8601withFractionalSeconds)))
}
