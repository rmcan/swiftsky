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
  @State var loading = true
  @State var error = ""
  @State var listheight = 40.0
  @Binding var path: [Navigation]
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
            path.append(.profile(user.actor.did))
          } label: {
            PostLikesSubview(avatar: user.actor.avatar, displayname: user.actor.displayName ?? user.actor.handle, handle: user.actor.handle)
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
  @State private var likedisabled: Bool = false
  @State private var repostdisabled: Bool = false
  @State private var likesunderline: Bool = false
  @State private var likespopover: Bool = false
  @State private var isrepostPresented: Bool = false
  @State private var isquotepostPresented: Bool = false
  @State private var isreplypostPresented: Bool = false
  @Binding var path: [Navigation]
  @AppStorage("hidelikecount") private var hidelikecount = false
  @AppStorage("hiderepostcount") private var hiderepostcount = false
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
      likedisabled = false
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
      likedisabled = false
    }
  }
  func repost() {
    post.viewer.repost = ""
    post.repostCount += 1
    Task {
      do {
        let result = try await RepostPost(uri: post.uri, cid: post.cid)
        post.viewer.repost = result.uri
      } catch {
        post.viewer.repost = nil
        post.repostCount -= 1
      }
      repostdisabled = false
    }
  }
  func undorepost() {
    let repost = post.viewer.repost
    post.viewer.repost = nil
    post.repostCount -= 1
    Task {
      do {
        if try await repoDeleteRecord(uri: repost!, collection: "app.bsky.feed.repost") {
          post.viewer.repost = nil
        }
      } catch {
        post.viewer.repost = repost
        post.repostCount += 1
      }
      repostdisabled = false
    }
  }
  var body: some View {
    HStack(alignment: .top, spacing: 0) {
      Button {
        isreplypostPresented.toggle()
      } label: {
        Text("\(Image(systemName: "bubble.right")) \(post.replyCount)")
      }
      .buttonStyle(.plain)
      .frame(width: 70, alignment: .leading)
      Button {
        isrepostPresented.toggle()
      } label: {
        Text("\(Image(systemName: "arrow.triangle.2.circlepath")) \(hiderepostcount ? "Hidden" : "\(post.repostCount)")")
          .foregroundColor(post.viewer.repost != nil ? .cyan : .secondary)
          .popover(isPresented: $isrepostPresented, arrowEdge: .bottom) {
            VStack(alignment: .leading) {
              Button {
                isrepostPresented = false
                repostdisabled = true
                post.viewer.repost == nil ? repost() : undorepost()
              } label : {
                Image(systemName: "arrowshape.turn.up.backward.fill")
                Text(post.viewer.repost == nil ? "Repost" : "Undo repost")
                  .font(.system(size: 15))
                  .frame(maxWidth: .infinity, alignment: .topLeading)
                  .contentShape(Rectangle())
              }
              .buttonStyle(.plain)
              .padding([.top, .leading], 10)
              .padding(.bottom, 2)
              .disabled(repostdisabled)
              Button {
                isquotepostPresented.toggle()
              } label : {
                Image(systemName: "quote.opening")
                Text("Quote Post")
                  .font(.system(size: 15))
                  .frame(maxWidth: .infinity, alignment: .topLeading)
                  .contentShape(Rectangle())
              }
              .buttonStyle(.plain)
              .padding(.leading, 10)
            }
            .frame(width: 150, height: 70, alignment: .topLeading)
          
          }
      }
      .buttonStyle(.plain)
      .frame(width: 70, alignment: .leading)
      Group {
        Button {
          if !likedisabled {
            likedisabled = true
            if post.viewer.like == nil {
              like()
            } else {
              unlike()
            }
          }
        } label: {
          Text("\(Image(systemName: "heart")) ")
        }
        .disabled(likedisabled)
        .buttonStyle(.plain)
        .frame(alignment: .leading)
        Text(hidelikecount ? "Hidden" : "\(post.likeCount)")
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
    .sheet(isPresented: $isquotepostPresented) {
      NewPostView(post: post, isquote: true)
        .frame(width: 600)
        .fixedSize()
    }
    .sheet(isPresented: $isreplypostPresented) {
      NewPostView(post: post)
        .frame(width: 600)
        .fixedSize()
    }
  }
}
