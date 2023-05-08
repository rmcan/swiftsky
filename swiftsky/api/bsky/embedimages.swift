//
//  embedimages.swift
//  swiftsky
//

struct LexLink: Codable, Hashable {
  let link: String
  enum CodingKeys: String, CodingKey {
    case link = "$link"
  }
}
struct LexBlob: Codable, Hashable {
  let type: String
  let ref: LexLink
  let mimeType: String
  let size: Int
  enum CodingKeys: String, CodingKey {
    case type = "$type"
    case ref
    case mimeType
    case size
  }
}
struct EmbedImagesImage: Codable, Hashable {
  let alt: String
  let image: LexBlob?
}
struct EmbedImagesViewImage: Decodable, Hashable {
  let alt: String
  let fullsize: String
  let thumb: String
}
