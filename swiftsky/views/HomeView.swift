//
//  HomeView.swift
//  swiftsky
//

import SwiftUI

struct HomeView: View {
    @State var timeline: FeedGetTimelineOutput = FeedGetTimelineOutput()
    @State var cursor: String? = ""
    var body: some View {
        NavigationStack{
            ScrollView() {
                LazyVStack(spacing: 0) {
                    ForEach(timeline.feed, id: \.self) { post in
                        NavigationLink(destination: ThreadView(viewpost: post.post, reply: post.reply)) {
                            PostView(post: post.post, reply: post.reply)
                                .padding([.top, .horizontal])
                                .contentShape(Rectangle())
                                .onAppear {
                                    if post == timeline.feed.last {
                                        if let cursor = self.cursor {
                                            getTimeline(before: cursor) { result in
                                                if let result = result {
                                                    self.timeline.feed.append(contentsOf: result.feed)
                                                    self.cursor = result.cursor
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        PostFooterView(post: post.post)
                            .padding(.leading, 68)
                        Divider()
                    }
                }
            }
        }
        .navigationTitle("Home")
        .onAppear {
            getTimeline() { result in
                if let result = result {
                    self.timeline = result
                    self.cursor = result.cursor
                }
            }
        }
    }
}
