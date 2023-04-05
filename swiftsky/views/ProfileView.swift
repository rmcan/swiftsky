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

struct ProfileView: View {
  let did: String
  @Namespace var namespace
  @State var showreplies = false
  @State var profile: ActorDefsProfileViewDetailed?
  @State var authorfeed = FeedGetAuthorFeedOutput()
  @State var previewurl: URL?
  @State private var disablefollowbutton = false
  @State var error: String? = nil
  @Binding var path: NavigationPath
  @State var loading: Bool = false
  func loadProfile() async {
    loading = true
    do {
      self.profile = try await actorgetProfile(actor: did)
      self.authorfeed = try await getAuthorFeed(actor: did)
    } catch {
      self.error = error.localizedDescription
    }
    loading = false
  }
  var body: some View {
    List {
      if let profile = profile {
        VStack(alignment: .leading) {
          ZStack(alignment: .bottomLeading) {
            if let banner = profile.banner {
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
            if let avatar = profile.avatar {
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
          HStack {
            Spacer()
            if NetworkManager.shared.did != profile.did {
              if let following = profile.viewer?.following {
                Button("\(Image(systemName: "checkmark")) Following") {
                  disablefollowbutton = true
                  Task {
                    do {
                      let result = try await repoDeleteRecord(
                        uri: following, collection: "app.bsky.graph.follow")
                      if result {
                        self.profile?.viewer?.following = nil
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
                        did: profile.did)
                      self.profile?.viewer?.following = result.uri
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
        
          VStack(alignment: .leading) {
            Text(profile.displayName ?? profile.handle)
              .font(.system(size: 30))
            HStack(spacing: 4) {
              if profile.viewer?.followedBy != nil {
                Text("Follows you")
              }
              Text("@\(profile.handle)").foregroundColor(.secondary)
            }
            .padding(.bottom, -3)
            HStack(spacing: 10) {
              Group {
                Button {
                  path.append(ProfileRouter.followers(profile.handle))
                } label: {
                  Text("\(profile.followersCount) \(Text("followers").foregroundColor(.secondary))")
                }
                .buttonStyle(.plain)
                Button {
                  path.append(ProfileRouter.following(profile.handle))
                } label: {
                  Text("\(profile.followsCount) \(Text("following").foregroundColor(.secondary))")
                }
                .buttonStyle(.plain)
              }
              .hoverHand()
              Text("\(profile.postsCount) \(Text("posts").foregroundColor(.secondary))")
            }
            .padding(.bottom, -5)
            if let description = profile.description {
              Text(.init(description)).textSelection(.enabled)
            }
          }
          .textSelection(.enabled)
          .padding(.top, 5)
          .padding(.leading, 20)
          .padding(.bottom, 20)
          HStack {
            Button {
              if (showreplies) {
                showreplies = false
              }
            } label: {
              VStack(alignment: .center, spacing: 0) {
                Text("Posts")
                  .hoverHand()
                if !showreplies {
                  Color.primary
                    .frame(height: 2)
                    .matchedGeometryEffect(id: "underline",
                                             in: namespace,
                                             properties: .frame)
                } else {
                  Color.clear.frame(height: 2)
                }
              }
              .animation(.spring(), value: showreplies)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: 40)
            Button {
              showreplies = true
            } label: {
              VStack(alignment: .center, spacing: 0) {
                Text("Posts & Replies")
                  .hoverHand()
                if showreplies {
                  Color.primary
                    .frame(height: 2)
                    .matchedGeometryEffect(id: "underline",
                                             in: namespace,
                                             properties: .frame)
                } else {
                  Color.clear.frame(height: 2)
                }
              }
              .animation(.spring(), value: showreplies)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: 100)
          }
          .padding(.leading, 20)
          Divider()
        }
        let filteredfeed = authorfeed.feed.filter {
          if showreplies {
            return true
          }
          return $0.reply == nil
        }
        ForEach(filteredfeed) { post in
          Group {
            PostView(
              post: post.post, reply: post.reply?.parent.author.handle, repost: post.reason,
              path: $path
            )
            .padding(.horizontal)
            .padding(.top, post != filteredfeed.first ? nil : 5)
            .contentShape(Rectangle())
            .onTapGesture {
              path.append(post)
            }
            .task {
              if post == authorfeed.feed.last {
                if let cursor = self.authorfeed.cursor {
                  do {
                    let result = try await getAuthorFeed(actor: profile.handle, cursor: cursor)
                    self.authorfeed.feed.append(contentsOf: result.feed)
                    self.authorfeed.cursor = result.cursor
                  } catch {
                    
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
        if self.authorfeed.cursor != nil {
          ProgressView().frame(maxWidth: .infinity, alignment: .center)
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
            await loadProfile()
          }
        } label: {
          Image(systemName: "arrow.clockwise")
        }
        .disabled(loading)
      }
    }
    .task {
      await loadProfile()
    }
    .quickLookPreview($previewurl)
  }
}
