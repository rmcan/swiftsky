//
//  repodeleteRecord.swift
//  swiftsky
//

import Foundation

struct RepoDeleteRecordInput: Encodable {
  let repo: String
  let collection: String
  let rkey: String
}

func repoDeleteRecord(uri: String, collection: String) async throws -> Bool {
  let aturi = AtUri(uri: uri)
  return try await Client.shared.fetch(
    endpoint: "com.atproto.repo.deleteRecord", httpMethod: .post,
    authorization: Client.shared.user.accessJwt,
    params: RepoDeleteRecordInput(
      repo: Client.shared.did, collection: collection, rkey: aturi.rkey))
}
