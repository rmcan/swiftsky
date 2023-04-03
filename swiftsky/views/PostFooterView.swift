//
//  PostFooterView.swift
//  swiftsky
//

import SwiftUI

struct PostFooterView: View {
  var bottompadding = true
  @State var post: FeedDefsPostView
  @State var locklike: Bool = false

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
    HStack(alignment: .firstTextBaseline, spacing: 32) {
      Label(String(post.replyCount), systemImage: "bubble.right")
      Label(String(post.repostCount), systemImage: "arrow.triangle.2.circlepath")
        .foregroundColor(post.viewer.repost != nil ? .cyan : .secondary)
      Label(String(post.likeCount), systemImage: "heart")
        .foregroundColor(post.viewer.like != nil ? .pink : .secondary)
        .onTapGesture {
          if !locklike {
            locklike = true
            if post.viewer.like == nil {
              like()
            } else {
              unlike()
            }
          }
        }
      Spacer()
    }
    .padding(.bottom, bottompadding ? 10 : 0)
    .foregroundColor(.secondary)
  }
}
