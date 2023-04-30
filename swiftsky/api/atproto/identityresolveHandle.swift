//
//  identityresolveHandle.swift
//  swiftsky
//

struct IdentityResolveHandleOutput: Decodable, Hashable {
  let did: String
}
func IdentityResolveHandle(handle: String) async throws -> IdentityResolveHandleOutput {
  return try await Client.shared.fetch(
    endpoint: "com.atproto.identity.resolveHandle", authorization: Client.shared.user.accessJwt,
    params: ["handle" : handle])
}
