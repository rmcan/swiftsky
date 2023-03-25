//
//  embedrecord.swift
//  swiftsky
//

struct EmbedRecordPresentedRecord: Decodable, Hashable {
  let author: ActorRefWithInfo
  let cid: String
  let record: FeedPost
  let uri: String
}
