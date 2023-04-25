//
//  PostFooterView.swift
//  swiftsky
//

import SwiftUI

struct PostLikesSubview: View {
  let avatar: String?
  let displayname: String
  let handle: String
  @State var usernamehover = false
  @Binding var path: NavigationPath
  var body: some View {
    HStack(alignment: .top) {
      AvatarView(url: avatar, size: 40)
      VStack(alignment: .leading) {
        Text(displayname)
          .foregroundColor(.primary)
          .lineLimit(1)
          .underline(usernamehover)
          .hoverHand {
            usernamehover = $0
          }
        Text("@\(handle)")
          .lineLimit(1)
          .foregroundColor(.secondary)
      }
    }
  }
}
struct PostLikesView: View {
  @State var post: FeedDefsPostView
  @State var likes = feedgetLikesOutput()
  @Binding var path: NavigationPath
  @State var loading = true
  @State var error = ""
  @State var listheight = 40.0
  private func getLikes() {
    Task {
      self.loading = true
      do {
        let likes = try await feedgetLikes(cid: post.cid, cursor: likes.cursor, uri: post.uri)
        self.likes.likes.append(contentsOf: likes.likes)
        self.likes.cursor = likes.cursor
        if !self.likes.likes.isEmpty {
          self.listheight = min(Double(self.likes.likes.count) * 42.0, 250)
        }
      } catch {
        if self.likes.likes.isEmpty {
          listheight = 80
        }
        self.error = error.localizedDescription
      }
      self.loading = false
    }
  
  }
  
  var body: some View {
    ScrollView {
      LazyVStack {
        if likes.likes.isEmpty && error.isEmpty && loading == false {
          VStack {
            Spacer()
            Text("This post doesnt have any likes yet")
              .frame(maxWidth: .infinity, alignment: .center)
            Spacer()
          }
       
        }
        ForEach(likes.likes) { user in
          Button {
            path.append(user.actor)
          } label: {
            PostLikesSubview(avatar: user.actor.avatar, displayname: user.actor.displayName ?? user.actor.handle, handle: user.actor.handle, path: $path)
              .frame(maxWidth: .infinity, alignment: .leading)
              .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
          .frame(height: 35)
          .task {
              if user.id == likes.likes.last?.id && likes.cursor != nil {
                getLikes()
              }
          }
        }
        
        if loading {
          ProgressView().frame(maxWidth: .infinity, alignment: .center)
        }
        if !self.error.isEmpty {
          Group {
            Text("Error: \(error)")
            Button("\(Image(systemName: "arrow.clockwise")) Retry") {
              error = ""
              getLikes()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
          }
          .frame(maxWidth: .infinity, alignment: .center)
        }
      }
      .padding(.top, 6)
      .padding(.leading, 6)
    }.task {
      getLikes()
    }
    .frame(width: 250, height: listheight)
  }
}

struct PostFooterView: View {
  var bottompadding = true
  var leadingpadding = 68.0
  @State var post: FeedDefsPostView
  @State var locklike: Bool = false
  @State var likesunderline: Bool = false
  @State var likespopover: Bool = false
  @Binding var path: NavigationPath
  func like() {
    post.viewer.like = ""
    post.likeCount += 1
    Task {
      do {
        let result = try await likePost(uri: post.uri, cid: post.cid)
        post.viewer.like = result.uri
      } catch {
        post.viewer.like = nil
        post.likeCount -= 1
      }
      locklike = false
    }
  }
  func unlike() {
    let like = post.viewer.like
    post.viewer.like = nil
    post.likeCount -= 1
    Task {
      do {
        if try await repoDeleteRecord(uri: like!, collection: "app.bsky.feed.like") {
          post.viewer.like = nil
        }
      } catch {
        post.viewer.like = like
        post.likeCount += 1
      }
      locklike = false
    }
  }
  var body: some View {
    HStack(alignment: .top, spacing: 0) {
      Button {
        
      } label: {
        Text("\(Image(systemName: "bubble.right")) \(post.replyCount)")
      }
      .buttonStyle(.plain)
      .frame(width: 70, alignment: .leading)
      Button {
        
      } label: {
        Text("\(Image(systemName: "arrow.triangle.2.circlepath")) \(post.repostCount)")
          .foregroundColor(post.viewer.repost != nil ? .cyan : .secondary)
      }
      .buttonStyle(.plain)
      .frame(width: 70, alignment: .leading)
      Group {
        Button {
          if !locklike {
            locklike = true
            if post.viewer.like == nil {
              like()
            } else {
              unlike()
            }
          }
        } label: {
          Text("\(Image(systemName: "heart")) ")
        }
        .disabled(locklike)
        .buttonStyle(.plain)
        .frame(alignment: .leading)
        Text("\(post.likeCount)")
          .underline(likesunderline)
          .hoverHand {
            likesunderline = $0
          }
          .onTapGesture {
            likespopover.toggle()
          }
          .popover(isPresented: $likespopover, arrowEdge: .bottom) {
            PostLikesView(post: post, path: $path)
          }
          .frame(alignment: .leading)
      }
      .foregroundColor(post.viewer.like != nil ? .pink : .secondary)
    }
    .padding(.bottom, bottompadding ? 10 : 0)
    .padding(.leading, leadingpadding)
    .foregroundColor(.secondary)
  }
}
