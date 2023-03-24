//
//  PostFooterView.swift
//  swiftsky
//

import SwiftUI

struct PostFooterView: View {
    var bottompadding = true
    @State var post: FeedPostView
    @State var lockupvote: Bool = false
    
    func upvote() {
        post.viewer.upvote = ""
        post.upvoteCount += 1
        Task {
            do {
                let result = try await FeedSetVote(uri: post.uri, cid: post.cid, direction: "up")
                post.viewer.upvote = result.upvote
            } catch {
                post.viewer.upvote = nil
                post.upvoteCount -= 1
            }
            lockupvote = false
        }
    }
    func downvote() {
        let upvote = post.viewer.upvote
        post.viewer.upvote = nil
        post.upvoteCount -= 1
        Task {
            do {
                let result = try await FeedSetVote(uri: post.uri, cid: post.cid, direction: "none")
                post.viewer.upvote = result.upvote
            } catch {
                post.viewer.upvote = upvote
                post.upvoteCount += 1
            }
            lockupvote = false
        }
    }
    var body: some View {
        
        HStack (alignment: .firstTextBaseline, spacing: 32) {
            Label(String(post.replyCount), systemImage: "bubble.right")
            Label(String(post.repostCount), systemImage: "arrow.triangle.2.circlepath")
                .foregroundColor(post.viewer.repost != nil ? .cyan : .secondary)
            Label(String(post.upvoteCount), systemImage: "heart")
                .foregroundColor(post.viewer.upvote != nil ? .pink : .secondary)
                .onTapGesture {
                    if !lockupvote {
                        lockupvote = true
                        if post.viewer.upvote == nil {
                            upvote()
                        }
                        else {
                            downvote()
                        }
                    }
                }
            Spacer()
        }
        .padding(.bottom, bottompadding ? 10 : 0)
        .foregroundColor(.secondary)
        
    }
    
}

