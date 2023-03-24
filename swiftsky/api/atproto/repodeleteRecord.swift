//
//  repodeleteRecord.swift
//  swiftsky
//

import Foundation

struct RepoDeleteRecordInput: Encodable {
    let did: String
    let collection: String
    let rkey: String
}

func RepoDeleteRecord(uri: String, collection: String) async throws -> Bool {
    let aturi = AtUri(uri: uri)
    return try await NetworkManager.shared.fetch(endpoint: "com.atproto.repo.deleteRecord", httpMethod: .POST, authorization: NetworkManager.shared.user.accessJwt, params: RepoDeleteRecordInput(did: NetworkManager.shared.did, collection: collection, rkey: aturi.rkey))
}
