//
//  repouploadBlob.swift
//  swiftsky
//

import Foundation

struct RepoUploadBlobOutput: Decodable {
  let blob: LexBlob
}
func repouploadBlob(data: Data) async throws -> RepoUploadBlobOutput {
  return try await Client.shared.upload(endpoint: "com.atproto.repo.uploadBlob", data: data, authorization: Client.shared.user.accessJwt)
}
