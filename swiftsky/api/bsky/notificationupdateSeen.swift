//
//  notificationupdateSeen.swift
//  swiftsky
//

import Foundation

func notificationUpdateSeen() async throws -> Bool {
  return try await Client.shared.fetch(
    endpoint: "app.bsky.notification.updateSeen", httpMethod: .post,
    authorization: Client.shared.user.accessJwt,
    params: ["seenAt" : Date().iso8601withFractionalSeconds])
}
