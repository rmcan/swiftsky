//
//  sessionget.swift
//  swiftsky
//

import Foundation

public struct SessionGetOutput: Decodable, Hashable {
    let did: String
    let handle: String
}

public func XrpcSessionGet() -> SessionGetOutput? {
    var output: SessionGetOutput? = nil
    let group = DispatchGroup()
    group.enter()
    api.shared.GET(endpoint: "com.atproto.session.get", objectType: SessionGetOutput.self, authorization: api.shared.user.accessJwt, refreshToken: true) { result in
        switch result {
        case .success(let result):
            output = result
        case .failure(let error):
            print(error)
        }
        group.leave()
    }
    group.wait()
    return output
}

