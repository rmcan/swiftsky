//
//  identityresolveHandle.swift
//  swiftsky
//

struct IdentityResolveHandleOutput: Decodable, Hashable {
  let did: String
}
func IdentityResolveHandle(handle: String) async throws -> IdentityResolveHandleOutput {
  return try await NetworkManager.shared.fetch(
    endpoint: "com.atproto.identity.resolveHandle", authorization: NetworkManager.shared.user.accessJwt,
    params: ["handle" : handle])
}
