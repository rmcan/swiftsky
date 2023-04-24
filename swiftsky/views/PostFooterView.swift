//
//  PostFooterView.swift
//  swiftsky
//

import SwiftUI

struct PostFooterView: View {
  var bottompadding = true
  var leadingpadding = 50.0
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
    HStack(alignment: .top, spacing: 0) {
      Button {
        
      } label: {
        Text("\(Image(systemName: "bubble.right")) \(post.replyCount)")
          .frame(width: 70)
      }
      .buttonStyle(.plain)
      .frame(width: 70)
      Button {
        
      } label: {
        Text("\(Image(systemName: "arrow.triangle.2.circlepath")) \(post.repostCount)")
          .foregroundColor(post.viewer.repost != nil ? .cyan : .secondary)
          .frame(width: 70)
      }
      .buttonStyle(.plain)
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
        Text("\(Image(systemName: "heart")) \(post.likeCount)")
          .foregroundColor(post.viewer.like != nil ? .pink : .secondary)
          .frame(width: 70)
      }
      .disabled(locklike)
      .buttonStyle(.plain)
      Spacer()
    }
    .padding(.bottom, bottompadding ? 10 : 0)
    .padding(.leading, leadingpadding)
    .foregroundColor(.secondary)
  }
}
