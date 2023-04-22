//
//  embedimages.swift
//  swiftsky
//

struct blob: Decodable, Hashable {
 // let ref: String
  let mimeType: String
 // let size: Int
}
struct EmbedImagesImage: Decodable, Hashable {
  let alt: String
  let image: blob?
}
struct EmbedImagesViewImage: Decodable, Hashable {
  let alt: String
  let fullsize: String
  let thumb: String
}
