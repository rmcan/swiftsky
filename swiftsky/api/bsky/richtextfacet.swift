//
//  richtextfacet.swift
//  swiftsky
//

struct RichtextFacetByteSlice: Codable, Hashable {
  let byteEnd: Int
  let byteStart: Int
}
struct RichtextFacetFeatures: Codable, Hashable {
  let type: String?
  let uri: String?
  let did: String?
  init(type: String? = nil, uri: String? = nil, did: String? = nil) {
    if uri != nil {
      self.type = "app.bsky.richtext.facet#link"
    }
    else if did != nil {
      self.type = "app.bsky.richtext.facet#mention"
    }
    else {
      self.type = type
    }
    self.uri = uri
    self.did = did
  }
  enum CodingKeys: String, CodingKey {
    case type = "$type"
    case uri
    case did
  }
}
struct RichtextFacet: Codable, Comparable, Hashable {
  static func < (lhs: RichtextFacet, rhs: RichtextFacet) -> Bool {
    lhs.index.byteStart < rhs.index.byteStart
  }
  let type: String = "app.bsky.richtext.facet"
  let features: [RichtextFacetFeatures]
  let index: RichtextFacetByteSlice
  enum CodingKeys: String, CodingKey {
    case type = "$type"
    case features
    case index
  }
}
