//
//  feeddefs.swift
//  swiftsky
//

import Foundation

struct FeedDefsGeneratorViewerState: Decodable, Hashable {
  var like: String?
}
struct FeedDefsGeneratorView: Decodable, Hashable, Identifiable {
  var id: String {
    cid
  }
  let avatar: String?
  let cid: String
  let creator: ActorDefsProfileView
  let description: String?
  let descriptionFacets: [RichtextFacet]?
  let did: String?
  let displayName: String
  let indexedAt: String
  var likeCount: Int?
  let uri: String
  var viewer: FeedDefsGeneratorViewerState?
}

struct FeedDefsViewerState: Decodable, Hashable {
  var like: String?
  var repost: String?
}
struct FeedDefsPostViewEmbed: Decodable, Hashable {
  let type: String?
  var images: [EmbedImagesViewImage]? = nil
  var external: EmbedExternalViewExternal? = nil
  var record: EmbedRecordViewRecord? = nil
  enum CodingKeys:String, CodingKey {
    case type = "$type"
    case images
    case external
    case record
    case media
    enum recordWithMedia: CodingKey {
        case record
        case images
    }
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.type = try container.decodeIfPresent(String.self, forKey: .type)
    switch type {
    case "app.bsky.embed.record#view":
      let recordcontainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .record)
      let type = try recordcontainer.decodeIfPresent(String.self, forKey: .type)
      if type == "app.bsky.embed.record#viewRecord" {
        self.record = try container.decodeIfPresent(EmbedRecordViewRecord.self, forKey: .record)
      }
    case "app.bsky.embed.recordWithMedia#view":
      let recordcontainer = try container.nestedContainer(keyedBy: CodingKeys.recordWithMedia.self, forKey: .record)
      self.record = try recordcontainer.decodeIfPresent(EmbedRecordViewRecord.self, forKey: .record)
      let mediacontainer = try container.nestedContainer(keyedBy: CodingKeys.recordWithMedia.self, forKey: .media)
      self.images = try mediacontainer.decodeIfPresent([EmbedImagesViewImage].self, forKey: .images)
    case "app.bsky.embed.images#view":
      self.images = try container.decodeIfPresent([EmbedImagesViewImage].self, forKey: .images)
    default:
      break
    }
    self.external = try container.decodeIfPresent(EmbedExternalViewExternal.self, forKey: .external)
  }
}
struct FeedDefsPostView: Decodable, Hashable {
  let author: ActorDefsProfileViewBasic
  var cid: String
  let embed: FeedDefsPostViewEmbed?
  let indexedAt: Date
  var likeCount: Int
  let record: FeedPost
  let replyCount: Int
  var repostCount: Int
  let uri: String
  var viewer: FeedDefsViewerState
}
struct FeedFeedViewPostReplyRef: Decodable, Hashable {
  let parent: FeedDefsPostView
  let root: FeedDefsPostView
}
struct FeedDefsFeedViewPostReason: Decodable, Hashable {
  let by: ActorDefsProfileViewBasic
  let indexedAt: String
}

struct FeedDefsFeedViewPost: Decodable, Hashable, Identifiable {
  let id = UUID()
  var post: FeedDefsPostView
  let reason: FeedDefsFeedViewPostReason?
  let reply: FeedFeedViewPostReplyRef?
  init(post: FeedDefsPostView, reason: FeedDefsFeedViewPostReason? = nil, reply: FeedFeedViewPostReplyRef? = nil) {
    self.post = post
    self.reason = reason
    self.reply = reply
  }
  enum CodingKeys: CodingKey {
    case post
    case reason
    case reply
  }
}
