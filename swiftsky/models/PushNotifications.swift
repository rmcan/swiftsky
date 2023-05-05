//
//  PushNotifications.swift
//  swiftsky
//

import Foundation

class PushNotificatios: ObservableObject {
  static let shared = PushNotificatios()
  var unreadcount: Int = 0
  private var backgroundtask: Task<Void, Never>?
  public func resumeRefreshTask() {
    self.backgroundtask?.cancel()
    self.backgroundtask = Task {
      while !Task.isCancelled {
        if Auth.shared.needAuthorization {
          break
        }
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
        try? await Task.sleep(nanoseconds: 30 * 1_000_000_000)
      }
    }
  }
  public func cancelRefreshTask() {
    self.backgroundtask?.cancel()
  }
  init() {
    if !Auth.shared.needAuthorization {
      resumeRefreshTask()
    }
  }
}
