//
//  HomeView.swift
//  swiftsky
//

import SwiftUI

struct HomeView: View {
  @State var timeline: FeedGetTimelineOutput = FeedGetTimelineOutput()
  @State var loading = false
  @Binding var path: [Navigation]
  func loadContent() async {
    loading = true
    do {
      self.timeline = try await getTimeline()
    } catch {
      print(error)
    }
    loading = false
  }
  var body: some View {
    List {
      Group {
        let filteredfeed = timeline.feed.filter {
          let reply = $0.reply?.parent.author
          let following = reply?.viewer?.following
          let repost = $0.reason
          return ((reply == nil || following != nil || reply?.did == Client.shared.did || $0.post.likeCount >= 5) || repost != nil)
        }
        if self.loading && !filteredfeed.isEmpty {
          ProgressView().frame(maxWidth: .infinity, alignment: .center)
        }
        ForEach(filteredfeed) { post in
          PostView(
            post: post.post, reply: post.reply?.parent.author.handle, repost: post.reason,
            path: $path
          )
          .padding([.top, .horizontal])
          .contentShape(Rectangle())
          .onTapGesture {
            path.append(.thread(post.post.uri))
          }
          .task {
            if post == filteredfeed.last {
              if let cursor = self.timeline.cursor {
                do {
                  let result = try await getTimeline(cursor: cursor)
                  self.timeline.feed.append(contentsOf: result.feed)
                  self.timeline.cursor = result.cursor
                } catch {
                  print(error)
                }
              }
            }
          }
          PostFooterView(post: post.post, path: $path)
          Divider()
        }
        if self.timeline.cursor != nil {
          ProgressView().frame(maxWidth: .infinity, alignment: .center)
        }
      }
      .listRowInsets(EdgeInsets())
      .listRowSeparator(.hidden)
    }
    .environment(\.defaultMinListRowHeight, 1)
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          Task {
            await loadContent()
          }
        } label: {
          Image(systemName: "arrow.clockwise")
        }
        .disabled(loading)
      }
    }
    .task() {
      await loadContent()
    }
  }
}
