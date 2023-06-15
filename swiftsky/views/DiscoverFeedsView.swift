//
//  DiscoverFeedsView.swift
//  swiftsky
//

import SwiftUI

struct FeedRowView: View {
  let feed: FeedDefsGeneratorView
  @EnvironmentObject private var preferences: PreferencesModel
  var isSaved: Bool {
    preferences.savedFeeds.contains(where: {
      feed.uri == $0
    })
  }
  var isPinned: Bool {
    preferences.pinnedFeeds.contains(where: {
      feed.uri == $0
    })
  }
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .top) {
        AvatarView(url: feed.avatar, size: 40, isFeed: true)
        VStack(alignment: .leading, spacing: 0) {
          Text(feed.displayName)
          Text("by @\(feed.creator.handle)")
            .foregroundStyle(.secondary)
        }
        Spacer()
        HStack {
          let saved = isSaved
          let pinned = isPinned
          if saved {
            Button {
              Task {
                if pinned {
                  await preferences.unpinfeed(uri: feed.uri)
                }
                else {
                  await preferences.addpinnedfeed(uri: feed.uri)
                }
              }
            } label: {
              Image(systemName: "pin")
                .foregroundStyle(pinned ? Color.accentColor : .secondary)
            }
            .buttonStyle(.plain)
            .font(.system(size: 18))
            .padding(.trailing, 5)
          }
      
          Button {
            Task {
              if saved {
                await preferences.deletefeed(uri: feed.uri)
              }
              else {
                SavedFeedsModel.shared.feedModelCache.setObject(CustomFeedModel(data: feed), forKey: feed.uri as NSString)
                await preferences.addsavedfeed(uri: feed.uri)
              }
            }
          } label: {
            Image(systemName: saved ? "trash" : "plus")
              .foregroundStyle(saved ? .secondary : Color.accentColor)
          }
          .buttonStyle(.plain)
          .font(.system(size: 18))
          .padding(.trailing, 5)
        }
     
      }
      if let description = feed.description {
        Text(description)
          .padding(.top, 10)
      }
      if let likeCount = feed.likeCount {
        Text("Liked by \(likeCount) users")
          .padding(.top, 5)
          .foregroundStyle(.secondary)
      }
    
    }
 

  }
}
struct DiscoverFeedsView: View {
  @State var feeds: [FeedDefsGeneratorView] = []
  @State var isLoading = false
  @Binding var path: [Navigation]
  func loadContent() async {
    isLoading = true
    do {
      let feeds = try await getPopularFeedGenerators()
      self.feeds = feeds.feeds
    } catch {
      print(error)
    }
    isLoading = false
  }
  var body: some View {
    List {
      Group {
        if isLoading {
          ProgressView().frame(maxWidth: .infinity, alignment: .center)
        }
        ForEach(feeds) { feed in
          FeedRowView(feed: feed)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            .onTapGesture {
              path.append(.feed(.init(data: feed)))
            }
          Divider()
        }
      }
      .listRowInsets(EdgeInsets())
      .listRowSeparator(.hidden)
    }
    .environment(\.defaultMinListRowHeight, 1)
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
    .task {
      await loadContent()
    }
  }
}

