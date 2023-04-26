//
//  HomeView.swift
//  swiftsky
//

import SwiftUI

struct HomeView: View {
  @State var timeline: FeedGetTimelineOutput = FeedGetTimelineOutput()
  @Binding var path: NavigationPath
  @State var loading = false
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
          return ((reply == nil || following != nil || reply?.did == NetworkManager().did) || repost != nil)
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
            path.append(post)
          }
          .task {
            if post == filteredfeed.last {
              if let cursor = self.timeline.cursor {
                do {
                  let result = try await getTimeline(cursor: cursor)
                  self.timeline.feed.append(contentsOf: result.feed)
                  self.timeline.cursor = result.cursor
                } catch {

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
    }
    .environment(\.defaultMinListRowHeight, 0.1)
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
    .task {
      await loadContent()
    }
  }
}
