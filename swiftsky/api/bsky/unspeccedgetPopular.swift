//
//  unspeccedgetPopular.swift
//  swiftsky
//

import Foundation

public struct UnspeccedGetPopularOutput: Decodable, Hashable, Identifiable {
    public static func == (lhs: UnspeccedGetPopularOutput, rhs: UnspeccedGetPopularOutput) -> Bool {
        return lhs.id == rhs.id
    }
    public var id: UUID {
        UUID()
    }
    var cursor: String? = ""
    var feed: [FeedFeedViewPost] = []
}

public func getPopular(before: String? = nil, completion: @escaping (UnspeccedGetPopularOutput?)->()) {
    var params : [String : String] = ["limit": "30"]
    if let before = before {
        params["before"] = before
    }
    api.shared.GET(endpoint: "app.bsky.unspecced.getPopular",params: params, objectType: UnspeccedGetPopularOutput.self, authorization: api.shared.user.accessJwt) { result in
        switch result {
        case .success(let result):
            completion(result)
        case .failure(let error):
            print(error)
            completion(nil)
        }
    }
}
