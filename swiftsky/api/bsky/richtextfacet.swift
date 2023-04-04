//
//  richtextfacet.swift
//  swiftsky
//

struct RichtextFacetByteSlice: Decodable, Hashable {
  let byteEnd: Int
  let byteStart: Int
}
struct RichtextFacetFeatures: Decodable, Hashable {
  let uri: String?
  let did: String?
}
struct RichtextFacet: Decodable, Hashable {
  let features: [RichtextFacetFeatures]
  let index: RichtextFacetByteSlice
}
