//
//  embedexternal.swift
//  swiftsky
//

import Foundation

struct EmbedExternalExternal: Decodable, Hashable {
    let description: String
    let thumb: blob?
    let title: String
    let uri: String
}
struct EmbedExternalPresentedExternal: Decodable, Hashable {
    let description: String
    let thumb: String?
    let title: String
    let uri: String
}
