//
//  sessionrefresh.swift
//  swiftsky
//

struct SessionRefreshOutput: Decodable, Hashable {
    let accessJwt: String
    let refreshJwt: String
    let handle: String
    let did: String
}
