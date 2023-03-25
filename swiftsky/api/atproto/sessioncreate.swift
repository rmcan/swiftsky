//
//  sessioncreate.swift
//  swiftsky
//

struct SessionCreateInput: Encodable {
  let identifier: String
  let password: String
}

struct SessionCreateOutput: Decodable, Hashable {
  let accessJwt: String
  let did: String
  let handle: String
  let refreshJwt: String
}

func xrpcSessionCreate(identifier: String, password: String) async throws -> SessionCreateOutput {
  return try await NetworkManager.shared.fetch(
    endpoint: "com.atproto.session.create", httpMethod: .post,
    params: SessionCreateInput(identifier: identifier, password: password))
}
