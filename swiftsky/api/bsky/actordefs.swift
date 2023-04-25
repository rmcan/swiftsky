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
}
struct ActorDefsProfileViewDetailed: Decodable, Hashable {
  let avatar: String?
  let banner: String?
  let description: String?
  let did: String
  let displayName: String?
  let followersCount: Int
  let followsCount: Int
  let handle: String
  let indexedAt: String?
  let postsCount: Int
  var viewer: ActorDefsViewerState?

  init(
    avatar: String? = nil, banner: String? = nil, description: String? = nil, did: String = "",
    displayName: String? = nil, followersCount: Int = 0, followsCount: Int = 0, handle: String = "",
    indexedAt: String? = nil, postsCount: Int = 0,
    viewer: ActorDefsViewerState? = nil
  ) {
    self.avatar = avatar
    self.banner = banner
    self.description = description
    self.did = did
    self.displayName = displayName
    self.followersCount = followersCount
    self.followsCount = followsCount
    self.handle = handle
    self.indexedAt = indexedAt
    self.postsCount = postsCount
    self.viewer = viewer
  }
}
