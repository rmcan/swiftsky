//
//  actorprofile.swift
//  swiftsky
//

struct ActorProfileMyState: Decodable, Hashable {
    let follow: String?
    let muted: Bool?
}
struct ActorProfileViewerState: Decodable, Hashable {
    let followedBy: String?
    var following: String?
    let muted: Bool?
}
public struct ActorProfileView: Decodable, Hashable {
    let avatar: String?
    let banner: String?
    let creator: String
    let declaration: SystemDeclRef
    let description: String?
    let did: String
    let displayName: String?
    let followersCount: Int
    let followsCount: Int
    let handle: String
    let indexedAt: String?
    let myState: ActorProfileMyState?
    let postsCount: Int
    var viewer: ActorProfileViewerState?
    
    init(avatar: String? = nil, banner: String? = nil, creator: String = "", declaration: SystemDeclRef = SystemDeclRef() , description: String? = nil, did: String =  "", displayName: String? = nil, followersCount: Int = 0,followsCount: Int =  0, handle: String = "", indexedAt: String? = nil, myState: ActorProfileMyState? = nil, postsCount: Int = 0, viewer: ActorProfileViewerState? = nil)
    {
        self.avatar = avatar
        self.banner = banner
        self.creator = creator
        self.declaration = declaration
        self.description = description
        self.did = did
        self.displayName = displayName
        self.followersCount = followersCount
        self.followsCount = followsCount
        self.handle = handle
        self.indexedAt = indexedAt
        self.myState = myState
        self.postsCount = postsCount
        self.viewer = viewer
    }
}


public func getProfile(actor: String, completion: @escaping (ActorProfileView?)->()) {
    api.shared.GET(endpoint: "app.bsky.actor.getProfile",params: ["actor": actor], objectType: ActorProfileView.self, authorization: api.shared.user.accessJwt) { result in
        switch result {
        case .success(let result):
            completion(result)
        case .failure(let error):
            print(error)
            completion(nil)
        }
    }
}

