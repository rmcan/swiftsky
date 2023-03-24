//
//  unspeccedgetPopular.swift
//  swiftsky
//

import Foundation

struct UnspeccedGetPopularInput: Encodable {
    let limit: Int = 30
    let before: String?
}

struct UnspeccedGetPopularOutput: Decodable, Hashable, Identifiable {
    public static func == (lhs: UnspeccedGetPopularOutput, rhs: UnspeccedGetPopularOutput) -> Bool {
        return lhs.id == rhs.id
    }
    public var id: UUID {
        UUID()
    }
    var cursor: String? = ""
    var feed: [FeedFeedViewPost] = []
}

func getPopular(before: String? = nil) async throws -> UnspeccedGetPopularOutput {
    return try await NetworkManager.shared.fetch(endpoint: "app.bsky.unspecced.getPopular", authorization: NetworkManager.shared.user.accessJwt, params: UnspeccedGetPopularInput(before: before))
}
