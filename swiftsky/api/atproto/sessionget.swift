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
  return try await Client.shared.fetch(
    endpoint: "com.atproto.server.getSession", authorization: Client.shared.user.accessJwt,
    params: Optional<Bool>.none)
}
