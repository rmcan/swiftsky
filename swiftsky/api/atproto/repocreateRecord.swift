//
//  repocreateRecord.swift
//  swiftsky
//

import Foundation

struct RepoCreateRecordOutput: Decodable {
  let cid: String
  let uri: String
}

struct FollowUserInput: Encodable {
  let subject: ActorRef
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
  let did: String
  let record: T
  enum CodingKeys: String, CodingKey {
    case type = "$type"
    case collection
    case did
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
func followUser(did: String, declarationCid: String) async throws -> RepoCreateRecordOutput {
  return try await repoCreateRecord(
    input: RepoCreateRecordInput(
      type: "app.bsky.graph.follow", collection: "app.bsky.graph.follow",
      did: NetworkManager.shared.did,
      record: FollowUserInput(
        subject: ActorRef(declarationCid: declarationCid, did: did),
        createdAt: Date().iso8601withFractionalSeconds)))
}
func makePost(text: String, reply: FeedPostReplyRef? = nil) async throws -> RepoCreateRecordOutput {
  return try await repoCreateRecord(
    input: RepoCreateRecordInput(
      type: "app.bsky.feed.post", collection: "app.bsky.feed.post", did: NetworkManager.shared.did,
      record: CreatePostInput(
        text: "test", createdAt: Date().iso8601withFractionalSeconds, reply: reply)))
}
