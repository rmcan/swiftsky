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
        if self.loading && !timeline.feed.isEmpty {
          ProgressView().frame(maxWidth: .infinity, alignment: .center)
        }
        ForEach(timeline.feed) { post in
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
            if post == timeline.feed.last {
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
          PostFooterView(post: post.post)
            .padding(.leading, 68)
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
