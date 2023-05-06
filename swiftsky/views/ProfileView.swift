//
//  ProfileView.swift
//  swiftsky
//

import QuickLook
import SwiftUI

private struct ProfileViewTabs: View {
  @Namespace var namespace
  @Binding var selectedtab: Int
  let tabs: [String]
  var body: some View {
    ForEach(tabs.indices, id: \.self) { i in
      Button {
        selectedtab = i
      } label: {
        Text(tabs[i])
          .padding(.bottom, 2)
          .overlay(alignment: .bottomLeading) {
            if selectedtab == i {
              Color.primary
                .frame(height: 2)
                .matchedGeometryEffect(id: "underline",
                                       in: namespace)
            }
          }
          .animation(.spring(), value: selectedtab)
      }
      .buttonStyle(.plain)
      .hoverHand()
    }
  }
}
struct ProfileView: View {
  let did: String
  @State var profile: ActorDefsProfileViewDetailed?
  @State private var authorfeed = FeedGetAuthorFeedOutput()
  @State private var likedposts = FeedGetAuthorFeedOutput()
  @State private var selectedtab = 0
  @State private var loading = false
  @State private var error = ""
  @State private var preview: URL? = nil
  @State private var disablefollowbutton = false
  @State private var disableblockbutton = false
  @State private var isblockalertPresented = false
  @Binding var path: [Navigation]
  let tablist: [String] = ["Posts", "Posts & Replies", "Likes"]
  private func getProfile() async {
    do {
      self.profile = try await actorgetProfile(actor: did)
    } catch {
    }
  }
  private func getFeed(cursor: String? = nil) async {
    do {
      let authorfeed = try await getAuthorFeed(actor: did, cursor: cursor)
      if cursor == nil {
        self.authorfeed = authorfeed
        return
      }
      self.authorfeed.cursor = authorfeed.cursor
      if !authorfeed.feed.isEmpty {
        self.authorfeed.feed.append(contentsOf: authorfeed.feed)
      }
    } catch {
      self.error = error.localizedDescription
    }
  }
  private func getLikes(cursor: String? = nil) async {
    do {
      let records = try await RepoListRecords(collection: "app.bsky.feed.like", cursor: cursor, limit: 25, repo: self.did)
      self.likedposts.cursor = records.cursor
      let uris = records.records.map {
        $0.value.subject.uri
      }
      if uris.isEmpty {
        return
      }
      let posts = try await feedgetPosts(uris: uris)
        .posts.map {
          FeedDefsFeedViewPost(post: $0)
        }
      if cursor != nil {
        self.likedposts.feed.append(contentsOf: posts)
      }
      else {
        self.likedposts.feed = posts
      }
      
    } catch {
      self.error = error.localizedDescription
    }
  }
  private func unfollow() {
    disablefollowbutton = true
    Task {
      do {
        let result = try await repoDeleteRecord(
          uri: profile!.viewer!.following!, collection: "app.bsky.graph.follow")
        if result {
          self.profile!.viewer!.following = nil
        }
      } catch {
        self.error = error.localizedDescription
      }
      disablefollowbutton = false
    }
  }
  private func unblock() {
    disableblockbutton = true
    Task {
      do {
        let result = try await repoDeleteRecord(
          uri: profile!.viewer!.blocking!, collection: "app.bsky.graph.block")
        if result {
          await load()
        }
      } catch {
        self.error = error.localizedDescription
      }
      disableblockbutton = false
    }
  }
  private func block() {
    disableblockbutton = true
    Task {
      do {
        let _ = try await blockUser(
          did: did)
        await load()
      } catch {
        self.error = error.localizedDescription
      }
      disableblockbutton = false
    }
  }
  private func follow() {
    disablefollowbutton = true
    Task {
      do {
        let result = try await followUser(
          did: did)
        profile!.viewer?.following = result.uri
      } catch {
        self.error = error.localizedDescription
      }
      disablefollowbutton = false
    }
  }
  var feedarray: [FeedDefsFeedViewPost] {
    switch selectedtab {
    case 1:
      return self.authorfeed.feed
    case 2:
      return likedposts.feed
    default:
      return self.authorfeed.feed.filter {
        return $0.post.record.reply == nil || $0.reason != nil
      }
    }
  }
  var isfollowing: Bool {
    return profile?.viewer?.following != nil
  }
  var followedby: Bool {
    return profile?.viewer?.followedBy != nil
  }
  var followbutton: some View {
    Button(isfollowing ? "\(Image(systemName: "checkmark")) Following" : "\(Image(systemName: "plus")) Follow") {
      isfollowing ? unfollow() : follow()
    }
    .buttonStyle(.borderedProminent)
    .tint(isfollowing ? Color(.controlColor) : Color.accentColor)
    .disabled(disablefollowbutton)
  }
  var unblockbutton: some View {
    Button("Unblock") {
      isblockalertPresented = true
    }
    .disabled(disableblockbutton)
  }
  private func load() async {
    loading = true
    await getProfile()
    if profile?.viewer?.blocking == nil {
      await getFeed()
      await getLikes()
    }
    loading = false
  }
  var header: some View {
    Group {
      if let banner = profile?.banner {
        Button {
          preview = URL(string: banner)
        } label: {
          AsyncImage(url: URL(string: banner)) { image in
            image
              .resizable()
              .scaledToFill()
              .frame(height: 200)
              .clipped()
          } placeholder: {
            ProgressView()
              .frame(height: 200)
              .frame(maxWidth: .infinity, alignment: .center)
          }
          .blur(radius: profile!.viewer?.blocking == nil ? 0 : 30, opaque: true)
        }
        .buttonStyle(.plain)
        
      }
      else {
        Color.accentColor.frame(height: 200)
      }
    }
    .frame(height: 240, alignment: .topLeading)
    .overlay(alignment: .bottomLeading) {
      HStack(spacing: 0) {
        Button {
          self.preview = URL(string: profile?.avatar ?? "")
        } label: {
          AvatarView(url: profile?.avatar, size: 80, blur: profile!.viewer?.blocking != nil)
            .overlay(
              Circle()
                .stroke(Color.white, lineWidth: 4)
                .frame(width: 80, height: 80)
            )
            .padding(.leading)
        }
        .buttonStyle(.plain)
        
        Spacer()
        Group {
          if profile!.did != Client.shared.did {
            if profile!.viewer?.blocking == nil {
              followbutton
            }
            else {
              unblockbutton
            }
          }
          Menu {
            ShareLink(item: URL(string: "https://staging.bsky.app/profile/\(profile!.handle)")!)
            if profile!.did != Client.shared.did && profile!.viewer?.blocking == nil {
              Button("Block") {
                isblockalertPresented = true
              }
            }
          
          } label: {
            Label("Details", systemImage: "ellipsis")
                .labelStyle(.iconOnly)
                .contentShape(Rectangle())
          }
          .menuStyle(.borderlessButton)
          .menuIndicator(.hidden)
          .fixedSize()
          .foregroundColor(.secondary)
          .hoverHand()
        }
        .padding(.top, 30)
        .padding(.trailing)
      }
    }
    .padding(.bottom, 2)
  }
  var blockedDescription: some View {
    ZStack(alignment: .leading) {
      RoundedRectangle(cornerRadius: 10)
        .opacity(0.05)
      Text("\(Image(systemName: "exclamationmark.triangle")) Account Blocked")
        .padding(3)
    }
    .padding(.trailing, 10)
    .padding(.bottom, 2)
  }
  var description: some View {
    Group {
      Text(profile!.displayName ?? profile!.handle)
        .font(.system(size: 30))
        .foregroundColor(.primary)
      if followedby {
        Text("Follows you")
          .padding(3)
          .background {
            RoundedRectangle(cornerRadius: 10)
              .opacity(0.1)
          }
      }
      Text("@\(profile!.handle)")
        .foregroundColor(.secondary)
        .padding(.bottom, 2)
      if profile!.viewer?.blocking != nil {
        blockedDescription
      }
      else {
        HStack {
          Button {
           path.append(.followers(profile!.handle))
          } label: {
            Text("\(profile!.followersCount) \(Text("followers").foregroundColor(.secondary))")
          }
          .buttonStyle(.plain)
          Button {
            path.append(.following(profile!.handle))
          } label: {
            Text("\(profile!.followsCount) \(Text("following").foregroundColor(.secondary))")
          }
          .buttonStyle(.plain)
          Text("\(profile!.postsCount) \(Text("posts").foregroundColor(.secondary))")
        }
        if let description = profile!.description, !description.isEmpty {
          Text(description)
        }
        HStack{
          ProfileViewTabs(selectedtab: $selectedtab, tabs: tablist)
        }
      }
     
    }
  }
  
  @ViewBuilder var feed: some View {
    let feed = feedarray
    ForEach(feed) { post in
      PostView(
        post: post.post, reply: post.reply?.parent.author.handle, repost: post.reason,
        path: $path
      )
      .padding(.horizontal)
      .padding(.top)
      .contentShape(Rectangle())
      .onTapGesture {
        path.append(.thread(post.post.uri))
      }
      .task {
        if post == feed.last {
          if selectedtab == 2, let cursor = likedposts.cursor {
            loading = true
            await getLikes(cursor: cursor)
            loading = false
          }
          else if let cursor = authorfeed.cursor {
            loading = true
            await getFeed(cursor: cursor)
            loading = false
          }
        }
      }
      PostFooterView(post: post.post, path: $path)
      Divider()
    }
  }
  var emptyfeed: some View {
    HStack(alignment: .center) {
      VStack(alignment: .center) {
        Image(systemName: "bubble.left")
          .resizable()
          .frame(width: 64, height: 64)
          .padding(.top)
        Text(selectedtab == 2 ? "@\(profile!.handle) doesn't have any likes yet!" : "No posts yet!")
          .fontWeight(.semibold)
      }
    }
    .foregroundColor(.secondary)
    .frame(maxWidth: .infinity, alignment: .center)
  }
  var body: some View {
    List {
      Group {
        if profile != nil {
          header
          Group {
            description
          }
          .padding(.leading, 10)
          if profile!.viewer?.blocking == nil {
            Divider().frame(height: 2)
              .padding(.top, 2)
            feed
            if loading {
              ProgressView().frame(maxWidth: .infinity, alignment: .center)
            }
            else if feedarray.isEmpty {
              emptyfeed
            }
          }
      
        }
      }
      .listRowInsets(.init())
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .environment(\.defaultMinListRowHeight, 0.1)
    .navigationTitle(profile?.handle ?? "Profile")
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          Task {
            await load()
          }
        } label: {
          Image(systemName: "arrow.clockwise")
        }
        .disabled(loading)
      }
    }
    .alert(error, isPresented: .constant(!error.isEmpty)) {
      Button("OK") {self.error = ""}
    }
    .alert(profile?.viewer?.blocking == nil ? "Blocked accounts cannot reply in your threads, mention you, or otherwise interact with you. You will not see their content and they will be prevented from seeing yours." : "The account will be able to interact with you after unblocking. (You can always block again in the future.)", isPresented: $isblockalertPresented) {
      Button(profile?.viewer?.blocking == nil ? "Block" : "Unblock", role: .destructive) {
        profile?.viewer?.blocking == nil ? block() : unblock()
      }

    }
    .quickLookPreview($preview)
    .task {
      await load()
    }
  }
}
