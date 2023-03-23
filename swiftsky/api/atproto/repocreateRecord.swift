//
//  repocreateRecord.swift
//  swiftsky
//

import Foundation

struct RepoCreateRecordOutput: Decodable {
    let cid: String
    let uri: String
}

func followUser(did: String,declarationCid: String, completion: @escaping (RepoCreateRecordOutput?)->()) {
    var params: [String:Any] = ["collection" : "app.bsky.graph.follow", "did" : api.shared.did]
    params["record"] = ["subject" : ["did" : did, "declarationCid" : declarationCid], "createdAt" : Date().iso8601withFractionalSeconds, "$type" : "app.bsky.graph.follow"]
    api.shared.POST(endpoint: "com.atproto.repo.createRecord", params: params, objectType: RepoCreateRecordOutput.self, authorization: api.shared.user.accessJwt) { result in
        switch result {
        case .success(let result):
            completion(result)
        case .failure(let error):
            print(error)
            completion(nil)
        }
    }
}

func makePost(text: String, completion: @escaping (RepoCreateRecordOutput?)->()) {
    var params: [String:Any] = ["collection" : "app.bsky.feed.post", "did" : api.shared.did]
    params["record"] = ["text": text, "createdAt" : Date().iso8601withFractionalSeconds, "$type" : "app.bsky.feed.post"]
    api.shared.POST(endpoint: "com.atproto.repo.createRecord", params: params, objectType: RepoCreateRecordOutput.self, authorization: api.shared.user.accessJwt) { result in
        switch result {
        case .success(let result):
            completion(result)
        case .failure(let error):
            print(error)
            completion(nil)
        }
    }
}
