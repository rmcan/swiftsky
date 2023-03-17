//
//  feedsetVote.swift
//  swiftsky
//

public struct FeedSetVoteOutput: Decodable, Hashable {
    let downvote: String?
    let upvote: String?
}

public func FeedSetVote(uri: String, cid: String, direction: String, completion: @escaping (FeedSetVoteOutput?)->()) {
    api.shared.POST(endpoint: "app.bsky.feed.setVote", params: ["subject" : ["uri" : uri, "cid" : cid], "direction": direction], objectType: FeedSetVoteOutput.self, authorization: api.shared.user.accessJwt) { result in
        switch result {
        case .success(let result):
            completion(result)
        case .failure(let error):
            print(error)
            completion(nil)
        }
    }
}
