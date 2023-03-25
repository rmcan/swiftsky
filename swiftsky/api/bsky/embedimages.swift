//
//  embedimages.swift
//  swiftsky
//

struct blob: Decodable, Hashable {
  let cid: String
  let mimeType: String
}
struct EmbedImagesImage: Decodable, Hashable {
  let alt: String
  let image: blob
}
struct EmbedImagesPresentedImage: Decodable, Hashable {
  let alt: String
  let fullsize: String
  let thumb: String
}
