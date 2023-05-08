//
//  feedpost.swift
//  swiftsky
//

import Foundation

struct RepoStrongRef: Codable, Hashable {
  let cid: String
  let uri: String
}

struct FeedPostReplyRef: Codable, Hashable {
  let parent: RepoStrongRef
  let root: RepoStrongRef
}

struct FeedPostTextSlice: Decodable, Hashable {
  let end: Int
  let start: Int
}

struct FeedPost: Decodable, Hashable {
  let createdAt: String
  let embed: FeedPostEmbed?
  let facets: [RichtextFacet]?
  let reply: FeedPostReplyRef?
  let text: String
}

struct FeedPostEmbed: Decodable, Hashable {
  let images: [EmbedImagesImage]?
  let external: EmbedExternalExternal?
  //let record: RepoStrongRef?
}

