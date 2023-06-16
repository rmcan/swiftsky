//
//  FeedView.swift
//  swiftsky
//

import SwiftUI

struct FeedView: View {
  var model: CustomFeedModel
  let header: Bool
  @State var feedview: FeedDefsGeneratorView? = nil
  @State var feed: [FeedDefsFeedViewPost] = []
  @State var cursor: String? = nil
  @State var isLoading = false
  @State var isLikeDisabled = false
  @Binding var path: [Navigation]
  @EnvironmentObject private var preferences: PreferencesModel
  func loadContent() async {
    isLoading = true
    do {
      if header {
        self.feedview = try await FeedGetFeedGenerator(feed: model.uri).view
      }
      let feed = try await FeedGetFeed(feed: model.uri, cursor: cursor)
      cursor = feed.cursor
      if self.feed.isEmpty {
        self.feed = feed.feed
      }
      else {
        self.feed.append(contentsOf: feed.feed)
      }
    } catch {
      print(error)
    }
    isLoading = false
  }
  var isSaved: Bool {
    preferences.savedFeeds.contains(where: {
      model.uri == $0
    })
  }
  var isPinned: Bool {
    preferences.pinnedFeeds.contains(where: {
      model.uri == $0
    })
  }
  func like() {
    Task {
      do {
        let result = try await likePost(uri: model.uri, cid: model.data.cid)
        feedview!.viewer!.like = result.uri
        feedview!.likeCount! += 1
      } catch {
       
      }
      isLikeDisabled = false
    }
  }
  func unlike() {
    let like = feedview!.viewer!.like
    Task {
      do {
        if try await repoDeleteRecord(uri: like!, collection: "app.bsky.feed.like") {
          feedview!.viewer!.like = nil
          feedview!.likeCount! -= 1
        }
      } catch {
        
      }
      isLikeDisabled = false
    }
  }
  @ViewBuilder var feedheader: some View {
    if header, let feedview = self.feedview {
      HStack(alignment: .top, spacing: 0) {
        AvatarView(url: feedview.avatar, size: 80, isFeed: true)
          .padding()
        VStack(alignment: .leading, spacing: 0) {
          Text(feedview.displayName)
            .font(.title)
          Text("by @\(feedview.creator.handle)")
            .foregroundStyle(.secondary)
          
          if let description = feedview.description {
            Text(description)
              .padding(.top, 5)
          }
          let saved = isSaved
          let pinned = isPinned
          HStack {
            Button {
              Task {
                if saved {
                  await preferences.deletefeed(uri: feedview.uri)
                }
                else {
                  SavedFeedsModel.shared.feedModelCache.setObject(CustomFeedModel(data: feedview), forKey: feedview.uri as NSString)
                  await preferences.addsavedfeed(uri: feedview.uri)
                }
              }
            } label: {
              Text(saved ? "Remove from My Feeds" : "Add to My Feeds")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
            }
            .buttonStyle(.borderedProminent)
            .tint(saved ? .secondary : .accentColor)
            .clipShape(Capsule())
            Button("\(Image(systemName: "pin"))") {
              Task {
                if pinned {
                  await preferences.unpinfeed(uri: model.uri)
                }
                else {
                  await preferences.addpinnedfeed(uri: model.uri)
                }
              }
            }
            .buttonStyle(.plain)
            .disabled(!saved)
            .foregroundStyle(pinned ? Color.accentColor : .primary)
            Button("\(Image(systemName: "hand.thumbsup")) \(feedview.likeCount ?? 0)") {
              if !isLikeDisabled {
                isLikeDisabled = true
                if feedview.viewer!.like == nil {
                  like()
                } else {
                  unlike()
                }
              }
            }
            .buttonStyle(.plain)
            .disabled(isLikeDisabled)
            .foregroundStyle(feedview.viewer!.like != nil ? .pink : .primary)
          }
          .padding(.top, 5)
        
        }
        .padding(.top)
      }
      .padding(.horizontal)
      .textSelection(.enabled)
      Divider()
        .padding(.top, 5)
    }
  }
  var body: some View {
    List {
      Group {
        if isLoading {
          ProgressView().frame(maxWidth: .infinity, alignment: .center)
        }
        feedheader
        ForEach(feed) { post in
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
            if post == feed.last && !isLoading && cursor != nil {
              await loadContent()
            }
          }
          PostFooterView(post: post.post, path: $path)
          Divider()
        }
        if cursor != nil {
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
        .disabled(isLoading)
      }
    }
    .task(id: model.uri) {
      feed = []
      cursor = nil
      await loadContent()
    }
  }
}
