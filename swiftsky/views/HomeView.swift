//
//  HomeView.swift
//  swiftsky
//

import SwiftUI

struct HomeView: View {
    @State var timeline: FeedGetTimelineOutput = FeedGetTimelineOutput()
    @State var cursor: String?
    @Binding var path: NavigationPath
    var body: some View {
        List(timeline.feed) { post in
            Group {
                Button {
                    path.append(post)
                } label: {
                    PostView(post: post.post, reply: post.reply, repost: post.reason, path: $path)
                        .padding([.top, .horizontal])
                        .contentShape(Rectangle())
                    
                }
                .buttonStyle(.plain)
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
                PostFooterView(post: post.post)
                    .padding(.leading, 68)
                Divider()
            }
            .listRowInsets(EdgeInsets())
        }
        .environment(\.defaultMinListRowHeight, 0.1)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
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
