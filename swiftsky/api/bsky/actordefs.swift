//
//  actordefs.swift
//  swiftsky
//

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
