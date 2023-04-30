//
//  repolistRecords.swift
//  swiftsky
//

struct RepoListRecordsOutput: Decodable {
  let cursor: String?
  let records: [RepoListRecordsRecord]
}
struct RepoListRecordsValue: Codable {
    let subject: RepoStrongRef
    let createdAt: String
}
struct RepoListRecordsRecord: Decodable {
  let cid: String
  let uri: String
  let value: RepoListRecordsValue
}
struct RepoListRecordsInput: Encodable {
  let collection: String
  let cursor: String?
  let limit: Int?
  let repo: String
}

func RepoListRecords(collection: String, cursor: String? = nil, limit: Int? = nil, repo: String) async throws -> RepoListRecordsOutput {
  return try await Client.shared.fetch(
    endpoint: "com.atproto.repo.listRecords", httpMethod: .get,
    params: RepoListRecordsInput(collection: collection, cursor: cursor, limit: limit, repo: repo))
}

