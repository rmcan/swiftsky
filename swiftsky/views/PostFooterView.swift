//
//  PostFooterView.swift
//  swiftsky
//

import SwiftUI

struct PostFooterView: View {
    @State var post: FeedPostView
    @State var lockupvote: Bool = false
    
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
                            post.viewer.upvote = ""
                            post.upvoteCount += 1
                            FeedSetVote(uri: post.uri, cid: post.cid, direction: "up") { result in
                                if let result = result {
                                    post.viewer.upvote = result.upvote
                                }
                                else {
                                    post.viewer.upvote = nil
                                    post.upvoteCount -= 1
                                }
                                lockupvote = false
                            }
                        }
                        else {
                            post.viewer.upvote = nil
                            post.upvoteCount -= 1
                            FeedSetVote(uri: post.uri, cid: post.cid, direction: "none") { result in
                                if let result = result {
                                    post.viewer.upvote = result.upvote
                                }
                                else {
                                    post.viewer.upvote = ""
                                    post.upvoteCount += 1
                                }
                                lockupvote = false
                            }
                        }
                    }
                }
            Spacer()
        }
        .padding(.bottom, 10)
        .foregroundColor(.secondary)
        
    }
    
}

