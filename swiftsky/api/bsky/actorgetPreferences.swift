//
//  actorgetPreferences.swift
//  swiftsky
//

import Foundation

enum ActorDefsPreferencesElem: Codable {
  case adultcontent(ActorDefsAdultContentPref)
  case contentlabel(ActorDefsContentLabelPref)
  case savedfeeds(ActorDefsSavedFeedsPref)
  case none
  enum CodingKeys: String, CodingKey {
      case type = "$type"
  }
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)
    switch type {
    case "app.bsky.actor.defs#adultContentPref":
      self = try .adultcontent(.init(from: decoder))
    case "app.bsky.actor.defs#contentLabelPref":
      self = try .contentlabel(.init(from: decoder))
    case "app.bsky.actor.defs#savedFeedsPref":
      self = try .savedfeeds(.init(from: decoder))
    default:
      self = .none
    }
  }
  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .adultcontent(let value):
      try container.encode(value)
    case .contentlabel(let value):
      try container.encode(value)
    case .savedfeeds(let value):
      try container.encode(value)
    default:
        break
    }
  }
  var feeds: ActorDefsSavedFeedsPref? {
    switch self {
    case .savedfeeds(let feeds):
      return feeds
    default:
      return nil
    }
  }
}
struct ActorGetPreferencesOutput: Decodable {
  let preferences: [ActorDefsPreferencesElem]
}

func ActorGetPreferences() async throws -> ActorGetPreferencesOutput {
  return try await Client.shared.fetch(
    endpoint: "app.bsky.actor.getPreferences", authorization: Client.shared.user.accessJwt,
    params: Optional<Bool>.none)
}
