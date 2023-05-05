//
//  NotificationsView.swift
//  swiftsky
//

import SwiftUI

private struct NotificationsViewFollow: View {
  @State var notification: NotificationListNotificationsNotification
  @State var underline = false
  var body: some View {
    Group {
      if let author = notification.author {
        
        HStack {
          Image(systemName: "person.crop.circle.badge.plus")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .clipped()
            .foregroundColor(.accentColor)
          AvatarView(url: author.avatar, size: 40)
          HStack(spacing: 3) {
            Text("@\(author.handle)")
              .foregroundColor(.primary)
              .underline(underline)
              .hoverHand {
                underline = $0
              }
            Text("followed you")
              .opacity(0.8)
            
            Text(
              Formatter.relativeDateNamed.localizedString(
                fromTimeInterval: notification.indexedAt.timeIntervalSinceNow)
            )
            .font(.body)
            .foregroundColor(.secondary)
          }
        }
      }
    }
  }
}

private struct NotificationsViewLike: View {
  @State var notification: NotificationListNotificationsNotification
  @State var underline = false
  var body: some View {
    Group {
      if let author = notification.author {
        
        HStack {
          Image(systemName: "heart.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25)
            .padding(5)
            .clipped()
            .foregroundColor(.pink)
          AvatarView(url: author.avatar, size: 40)
          HStack(spacing: 3) {
            Text("@\(author.handle)")
              .foregroundColor(.primary)
              .underline(underline)
              .hoverHand {
                underline = $0
              }
            Text("liked your post")
              .opacity(0.8)
            
            Text(
              Formatter.relativeDateNamed.localizedString(
                fromTimeInterval: notification.indexedAt.timeIntervalSinceNow)
            )
            .font(.body)
            .foregroundColor(.secondary)
          }
        }
      }
    }
  }
}
struct NotificationsView: View {
  @State var notifications: NotificationListNotificationsOutput?
  func getNotifications(cursor: String? = nil) async {
    do {
      let notifications = try await NotificationListNotifications(cursor: cursor)
      if cursor != nil {
        self.notifications?.notifications.append(contentsOf: notifications.notifications)
        self.notifications?.cursor = notifications.cursor
      }
      else {
        self.notifications = notifications
      }
      let uris = notifications.notifications.compactMap {
        if $0.uri.contains("app.bsky.feed.post") {
          return $0.uri
        }
        return nil
      }
      let posts = try await feedgetPosts(uris: uris)
      for post in posts.posts {
        if let notif = self.notifications?.notifications.firstIndex(where: {
          $0.uri == post.uri
        }) {
          self.notifications?.notifications[notif].post = post
          
        }
      }
      
    } catch {
    }
  }
  var body: some View {
    List {
      Group {
        if let notifications {
          ForEach(notifications.notifications) { notification in
            Group {
              if notification.reason == "follow" {
                NotificationsViewFollow(notification: notification)
                  .padding(.bottom, 5)
              }
              else if notification.reason == "like" {
                NotificationsViewLike(notification: notification)
                  .padding(.bottom, 5)
              }
              if let post = notification.post {
                PostView(post: post, path: .constant(NavigationPath()))
                  .padding([.horizontal, .top])
                PostFooterView(post: post, path: .constant(NavigationPath()))
                  .frame(maxWidth: .infinity, alignment: .topLeading)
              }
            }
            .background {
              if !notification.isRead {
                Color.blue
                  .opacity(0.5)
              }
            }
            .onAppear {
              Task {
                if let cursor = notifications.cursor, notification.cid == notifications.notifications.last?.cid {
                  await getNotifications(cursor: cursor)
                }
              }
              
            }
            Divider()
              .padding(.bottom, 5)
          }
        }
      }
      .listRowInsets(EdgeInsets())
    }
    .listStyle(.plain)
    .environment(\.defaultMinListRowHeight, 0.1)
    .scrollContentBackground(.hidden)
    .task {
      await getNotifications()
      PushNotificatios.shared.markasRead()
    }
  }
}
