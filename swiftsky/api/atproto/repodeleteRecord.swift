//
//  repodeleteRecord.swift
//  swiftsky
//

import Foundation

func unfollowUser(did: String, rkey: String, completion: @escaping (Bool)->()) {
    api.shared.POST(endpoint: "com.atproto.repo.deleteRecord", params: ["collection" : "app.bsky.graph.follow", "did" : api.shared.did, "rkey" : rkey], objectType: Bool.self, authorization: api.shared.user.accessJwt) { result in
        switch result {
        case .success(let result):
            completion(result)
        case .failure(let error):
            print(error)
            completion(false)
        }
    }
}

func deletePost(uri: String, completion: @escaping (Bool)->()) {
    let aturi = AtUri(uri: uri)
    api.shared.POST(endpoint: "com.atproto.repo.deleteRecord", params: ["collection" : "app.bsky.feed.post", "did" : api.shared.did, "rkey" : aturi.rkey], objectType: Bool.self, authorization: api.shared.user.accessJwt) { result in
        switch result {
        case .success(let result):
            completion(result)
        case .failure(let error):
            print(error)
            completion(false)
        }
    }
}
