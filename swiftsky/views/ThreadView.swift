//
//  ThreadView.swift
//  swiftsky
//

import SwiftUI

struct ThreadView: View {
    @State var viewpost: FeedPostView
    @State var reply: FeedFeedViewPostReplyRef?
    
    @State var timeline: FeedGetTimelineOutput = FeedGetTimelineOutput()
    @State var replies: [FeedGetPostThreadThreadViewPost]?
    @State var doreply: String = ""
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let reply = reply {
                    NavigationLink(destination: ThreadView(viewpost: reply.parent)) {
                        PostView(post: reply.parent)
                            .padding([.top,.horizontal])
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    PostFooterView(post: reply.parent)
                        .padding(.leading, 67.0)
                }
                Divider()
                
                PostView(post: viewpost, reply: reply)
                    .padding([.top, .horizontal])
                PostFooterView(post: viewpost)
                    .padding(.leading, 67.0)
                Divider()
                HStack (spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 40))
                        .padding(.leading)
                    
                    TextField("Reply to @\(viewpost.author.handle)", text: $doreply, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                        .padding([.top,.trailing])
                    
                }
                HStack {
                    Spacer()
                    Button("Reply (WIP)", action: {})
                        .keyboardShortcut(.defaultAction)
                        .disabled(true)
                        .padding([.bottom, .trailing])
                        .padding(.top, 10)
                }
                Divider()
                if let replies = replies {
                    ForEach(replies, id: \.self) { post in
                        NavigationLink(destination: ThreadView(viewpost: post.post)) {
                            HStack {
                                PostView(post: post.post)
                                    .padding([.top, .horizontal])
                                    .contentShape(Rectangle())
                                
                            }
                            
                        }.buttonStyle(.plain)
                        PostFooterView(post: post.post)
                            .padding(.leading, 67.0)
                        Divider()
                    }
                }
                
            }
        }.navigationTitle("Post")
        .onAppear {
            getPostThread(uri: viewpost.uri) { result in
                if let result = result {
                    if let thread = result.thread {
                        self.replies = thread.replies
                    }
                }
            }
        }
    }
}

