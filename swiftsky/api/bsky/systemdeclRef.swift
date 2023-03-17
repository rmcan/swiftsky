//
//  systemdeclRef.swift
//  swiftsky
//

struct SystemDeclRef: Decodable, Hashable {
    let actorType: String
    let cid: String
    
    init(actorType: String = "", cid: String = "") {
        self.actorType = actorType
        self.cid = cid
    }
}

