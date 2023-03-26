//
//  actorref.swift
//  swiftsky
//

struct ActorRef: Codable, Hashable {
  let declarationCid: String
  let did: String
}

struct ActorRefViewerState: Decodable, Hashable {
  var followedBy: String?
  var following: String?
  var muted: Bool?
}

struct ActorRefWithInfo: Decodable, Hashable, Identifiable {
  var id: String {
    did
  }
  let avatar: String?
  let declaration: SystemDeclRef
  let did: String
  let displayName: String?
  let handle: String
  var viewer: ActorRefViewerState?
}
