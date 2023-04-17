//
//  ProfileView.swift
//  swiftsky
//

import QuickLook
import SwiftUI

enum ProfileRouter: Hashable {
   case followers(String)
   case following(String)
}
private struct ProfileViewHeader: View {
  @State var previewurl: URL? = nil
  let banner: String?
  let avatar: String?
  var body: some View {
    ZStack(alignment: .bottomLeading) {
      if let banner = banner {
        CachedAsyncImage(url: URL(string: banner)) { image in
          image
            .resizable()
            .frame(height: 200)
        } placeholder: {
          ProgressView()
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .onTapGesture {
          previewurl = URL(string: banner)
        }
      } else {
        Color(.controlAccentColor)
          .frame(height: 200)
      }
      if let avatar = avatar {
        AvatarView(url: URL(string: avatar)!, size: 80)
          .offset(x: 20, y: 40)
          .onTapGesture {
            previewurl = URL(string: avatar)
          }
      } else {
        Image(systemName: "person.crop.circle.fill")
          .resizable()
          .overlay(
            Circle()
              .stroke(Color.white, lineWidth: 4)
              .frame(width: 80, height: 80)
          )
          .foregroundStyle(.white, Color.accentColor)
          .frame(width: 80, height: 80)
          .offset(x: 20, y: 40)
      }
    }
    .quickLookPreview($previewurl)
  }
}
private struct ProfileViewFollow: View {
  let did: String
  @State var following: String?
  @State var disablefollowbutton: Bool = false
  var body: some View {
    HStack {
      Spacer()
      if NetworkManager.shared.did != did {
        if let following {
          Button("\(Image(systemName: "checkmark")) Following") {
            disablefollowbutton = true
            Task {
              do {
                let result = try await repoDeleteRecord(
                  uri: following, collection: "app.bsky.graph.follow")
                if result {
                  self.following = nil
                }
              } catch {

              }
              disablefollowbutton = false
            }
          }
          .disabled(disablefollowbutton)
        } else {
          Button("\(Image(systemName: "plus")) Follow") {
            disablefollowbutton = true
            Task {
              do {
                let result = try await followUser(
                  did: did)
                self.following = result.uri
              } catch {
                print(error)
              }
              disablefollowbutton = false
            }
          }
          .disabled(disablefollowbutton)
          .buttonStyle(.borderedProminent)
          .tint(.accentColor)
        }
      }

      Button {

      } label: {
        Image(systemName: "ellipsis")
      }
      .padding(.trailing, 10)
    }
  }
}
private struct ProfileViewDetails: View {
  let handle: String
  let displayName: String?
  let followedBy: String?
  let followersCount: Int
  let followsCount: Int
  let description: String?
  let postsCount: Int
  @Binding var path: NavigationPath
  var body: some View {
    VStack(alignment: .leading) {
      Text(self.displayName ?? self.handle)
        .font(.system(size: 30))
      HStack(spacing: 4) {
        if followedBy != nil {
          Text("Follows you")
        }
        Text("@\(self.handle)").foregroundColor(.secondary)
      }
      .padding(.bottom, -3)
      HStack(spacing: 10) {
        Group {
          Button {
            path.append(ProfileRouter.followers(self.handle))
          } label: {
            Text("\(self.followersCount) \(Text("followers").foregroundColor(.secondary))")
          }
          .buttonStyle(.plain)
          Button {
            path.append(ProfileRouter.following(self.handle))
          } label: {
            Text("\(self.followsCount) \(Text("following").foregroundColor(.secondary))")
          }
          .buttonStyle(.plain)
        }
        .hoverHand()
        Text("\(self.postsCount) \(Text("posts").foregroundColor(.secondary))")
      }
      .padding(.bottom, -5)
      if let description {
        Text(.init(description)).textSelection(.enabled)
      }
    }
    .textSelection(.enabled)
    .padding(.top, 5)
    .padding(.leading, 20)
    .padding(.bottom, 20)
  }
}
private struct ProfileViewTabs: View {
  @Namespace var namespace
  @Binding var selectedtab: Int
  var body: some View {
    HStack {
      Button {
        selectedtab = 0
      } label: {
        VStack(alignment: .center, spacing: 0) {
          Text("Posts")
            .hoverHand()
          if selectedtab == 0 {
            Color.primary
              .frame(height: 2)
              .matchedGeometryEffect(id: "underline",
                                       in: namespace,
                                       properties: .frame)
          }
        }
        .animation(.spring(), value: selectedtab)
      }
      .buttonStyle(.plain)
      .frame(maxWidth: 40)
      Button {
        selectedtab = 1
      } label: {
        VStack(alignment: .center, spacing: 0) {
          Text("Posts & Replies")
            .hoverHand()
          if selectedtab == 1 {
            Color.primary
              .frame(height: 2)
              .matchedGeometryEffect(id: "underline",
                                       in: namespace,
                                       properties: .frame)
          }
        }
        .animation(.spring(), value: selectedtab)
      }
      .buttonStyle(.plain)
      .frame(maxWidth: 100)
      Button {
        selectedtab = 2
      } label: {
        VStack(alignment: .center, spacing: 0) {
          Text("Likes")
            .hoverHand()
          if selectedtab == 2 {
            Color.primary
              .frame(height: 2)
              .matchedGeometryEffect(id: "underline",
                                       in: namespace,
                                       properties: .frame)
          }
        }
        .animation(.spring(), value: selectedtab)
      }
      .buttonStyle(.plain)
      .frame(maxWidth: 40)
    }
    .padding(.leading, 20)
  }
}
private struct ProfileViewFeed: View {
  let handle: String
  let feed: [FeedDefsFeedViewPost]
  @Binding var path: NavigationPath
  let loadMorePosts: () async -> ()
  var body: some View {
    ForEach(feed) { post in
      Group {
        PostView(
          post: post.post, reply: post.reply?.parent.author.handle, repost: post.reason,
          path: $path
        )
        .padding(.horizontal)
        .padding(.top, post != feed.first ? nil : 5)
        .contentShape(Rectangle())
        .onTapGesture {
          path.append(post)
        }
        .task {
          if post == feed.last {
            await loadMorePosts()
          }
        }
        PostFooterView(post: post.post)
          .padding(.leading, 68)

        Divider()
      }
      .listRowInsets(EdgeInsets())
    }
  }
}
struct ProfileView: View {
  let did: String
  @State var selectedtab = 0
  @State var profile: ActorDefsProfileViewDetailed?
  @State var authorfeed = FeedGetAuthorFeedOutput()
  @State var likedposts = FeedGetAuthorFeedOutput()
  @State private var disablefollowbutton = false
  @State var error: String? = nil
  @Binding var path: NavigationPath
  @State var loading: Bool = false
  func loadProfile() async {
    do {
      self.profile = try await actorgetProfile(actor: did)
      self.authorfeed = try await getAuthorFeed(actor: did)
    } catch {
      self.error = error.localizedDescription
    }
  }
  var feed: [FeedDefsFeedViewPost] {
    switch selectedtab {
    case 1:
      return self.authorfeed.feed
    case 2:
      return likedposts.feed
    default:
      return self.authorfeed.feed.filter {
        return $0.reply == nil
      }
    }
  }
  func getLikes(cursor: String? = nil) async {
    do {
      var likedposts: [FeedDefsFeedViewPost] = []
      let records = try await RepoListRecords(collection: "app.bsky.feed.like", cursor: cursor, limit: 10, repo: self.did)
      for record in records.records {
        let postthread = try? await getPostThread(uri: record.value.subject.uri)
        if let postthread {
          if let thread = postthread.thread {
            if let post = thread.post {
              likedposts.append(FeedDefsFeedViewPost(post: post, reason: nil, reply: nil))
            }
          }
        }
      }
      
      if cursor == nil {
        self.likedposts.feed = likedposts
      }
      else {
        self.likedposts.feed.append(contentsOf: likedposts)
      }
      self.likedposts.cursor = records.cursor
    } catch {
      self.error = error.localizedDescription
    }
  }
  var body: some View {
    List {
      if let profile {
        VStack(alignment: .leading) {
          ProfileViewHeader(banner: profile.banner, avatar: profile.avatar)
          ProfileViewFollow(did: did, following: self.profile?.viewer?.following)
          ProfileViewDetails(handle: profile.handle, displayName: profile.displayName, followedBy: profile.viewer?.followedBy, followersCount: profile.followersCount, followsCount: profile.followsCount, description: profile.description, postsCount: profile.postsCount, path: $path)
          ProfileViewTabs(selectedtab: $selectedtab)
          Divider()
        }
        ProfileViewFeed(handle: profile.handle, feed: feed, path: $path) {
          if selectedtab == 2, let cursor = likedposts.cursor {
             await getLikes(cursor: cursor)
          }
          else if let cursor = self.authorfeed.cursor {
            do {
              let result = try await getAuthorFeed(actor: profile.handle, cursor: cursor)
              self.authorfeed.feed.append(contentsOf: result.feed)
              self.authorfeed.cursor = result.cursor
            } catch {

            }
          }
        }
        if selectedtab == 2 ? self.likedposts.cursor != nil : self.authorfeed.cursor != nil {
          ProgressView().frame(maxWidth: .infinity, alignment: .center)
        } else if feed.isEmpty {
          HStack(alignment: .center) {
            VStack(alignment: .center) {
              Image(systemName: "bubble.left")
                .resizable()
                .frame(width: 64, height: 64)
                .padding(.top)
              Text(selectedtab == 2 ? "@\(profile.handle) doesn't have any likes yet!" : "No posts yet!")
                .fontWeight(.semibold)
            }
          }
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, alignment: .center)
        }
      }
    }
    .navigationTitle(profile?.handle ?? "Profile")
    .environment(\.defaultMinListRowHeight, 0.1)
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
    .alert(error ?? "", isPresented: .constant(error != nil)) {
      Button("OK") {error = nil}
    }
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          Task {
            loading = true
            await loadProfile()
            await getLikes()
            loading = false
          }
        } label: {
          Image(systemName: "arrow.clockwise")
        }
        .disabled(loading)
      }
    }
    .task {
      loading = true
      await loadProfile()
      await getLikes()
      loading = false
    }
  }
}
