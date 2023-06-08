//
//  PopularView.swift
//  swiftsky
//

import SwiftUI

struct PopularView: View {
  @AppStorage("disablelanguageFilter") private var disablelanguageFilter = false
  @State var timeline: UnspeccedGetPopularOutput = UnspeccedGetPopularOutput()
  @State var loading = false
  @Binding var path: [Navigation]
  func loadContent() async {
    loading = true
      do {
        self.timeline = try await getPopular()
      } catch {

      }
      loading = false
  }
  var body: some View {
    List {
      Group {
        let filteredfeed = timeline.feed.filter {
          if disablelanguageFilter {
            return true
          }
          let text = $0.post.record.text
          let langcode = text.isEmpty ? "en" : $0.post.record.text.languageCode
          return langcode == "en" || Locale.preferredLanguageCodes.contains(langcode)
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
                  let result = try await getPopular(cursor: cursor)
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
    .task {
      await loadContent()
    }

  }
}
