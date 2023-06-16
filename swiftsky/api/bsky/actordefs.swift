//
//  actordefs.swift
//  swiftsky
//

struct ActorDefsSavedFeedsPref: Codable {
  let type = "app.bsky.actor.defs#savedFeedsPref"
  var pinned: [String]
  var saved: [String]
  enum CodingKeys: String, CodingKey {
    case type = "$type"
    case pinned
    case saved
  }
}
struct ActorDefsAdultContentPref: Codable {
  let type: String = "app.bsky.actor.defs#adultContentPref"
  let enabled: Bool
  enum CodingKeys: String, CodingKey {
    case type = "$type"
    case enabled
  }
}
struct ActorDefsContentLabelPref: Codable {
  let type = "app.bsky.actor.defs#contentLabelPref"
  let label: String
  let visibility: String
  enum CodingKeys: String, CodingKey {
    case type = "$type"
    case label
    case visibility
  }
}

struct ActorDefsProfileView: Decodable, Hashable, Identifiable {
  var id: String {
    did
  }
  let avatar: String?
  let description: String?
  let did: String
  let displayName: String?
  let handle: String
  let indexedAt: String?
  var viewer: ActorDefsViewerState?
}

struct ActorDefsProfileViewBasic: Decodable, Hashable, Identifiable {
  var id: String {
    did
  }
  let avatar: String?
  let did: String
  let displayName: String?
  let handle: String
  var viewer: ActorDefsViewerState?
}

struct ActorDefsViewerState: Decodable, Hashable {
  let followedBy: String?
  var following: String?
  let muted: Bool?
  var blocking: String?
}
struct ActorDefsProfileViewDetailed: Decodable, Hashable {
  let avatar: String?
  let banner: String?
  let description: String?
  let did: String
  let displayName: String?
  var followersCount: Int
  var followsCount: Int
  let handle: String
  let indexedAt: String?
  let postsCount: Int
  var viewer: ActorDefsViewerState?
}
