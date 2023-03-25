//
//  sessionget.swift
//  swiftsky
//

import Foundation

struct SessionGetOutput: Decodable, Hashable {
  let did: String
  let handle: String
}

func xrpcSessionGet() async throws -> SessionGetOutput {
  return try await NetworkManager.shared.fetch(
    endpoint: "com.atproto.session.get", authorization: NetworkManager.shared.user.accessJwt,
    params: Optional<Bool>.none)
}
