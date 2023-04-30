//
//  repogetRecord.swift
//  swiftsky
//

struct RepoGetRecordOutput: Decodable {
  let cid: String?
  let uri: String
 // let value: FeedPost
}
struct RepoGetRecordInput: Encodable {
  let cid: String?
  let collection: String
  let repo: String
  let rkey: String
}

func RepoGetRecord(cid: String? = nil, collection: String, repo: String, rkey: String) async throws -> RepoGetRecordOutput {
  return try await Client.shared.fetch(
    endpoint: "com.atproto.repo.getRecord", httpMethod: .get,
    params: RepoGetRecordInput(cid: cid, collection: collection, repo: repo, rkey: rkey))
}
