//
//  actorref.swift
//  swiftsky
//

struct ActorRef: Codable, Hashable {
    let declarationCid: String
    let did: String
}

struct ActorRefViewerState: Decodable, Hashable{
    let followedBy: String?
    let following: String?
    let muted: Bool?
}

struct ActorRefWithInfo: Decodable, Hashable{
    let avatar: String?
    let declaration: SystemDeclRef
    let did: String
    let displayName: String?
    let handle: String
    let viewer: ActorRefViewerState?
}
