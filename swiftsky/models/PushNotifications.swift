//
//  PushNotifications.swift
//  swiftsky
//

import Foundation

class PushNotificatios: ObservableObject {
  static let shared = PushNotificatios()
  var unreadcount: Int = 0
  init() {
    Task {
      while true {
        if let notifications = try? await NotificationListNotifications().notifications {
          let unreadnotifications = notifications.filter {
            !$0.isRead
          }
          if self.unreadcount != unreadnotifications.count {
            self.unreadcount = unreadnotifications.count
            DispatchQueue.main.async {
              self.objectWillChange.send()
            }
          }
        }
        try! await Task.sleep(nanoseconds: 30 * 1_000_000_000)
      }
    }
  }
}
