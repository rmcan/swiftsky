//
//  SidebarView.swift
//  swiftsky
//

import SwiftUI

struct SidebarView: View {
  @State var profile: ActorDefsProfileViewDetailed = ActorDefsProfileViewDetailed ()
  @StateObject private var auth = Auth.shared
  @State private var selection: Int = -1
  @State private var path = NavigationPath()
  @State var compose: Bool = false
  @State var replypost: Bool = false
  @State private var post: FeedDefsPostView? = nil
  @State var searchactors = ActorSearchActorsTypeaheadOutput()
  @State var searchpresented = false
  func loadProfile() async {
    do {
      self.profile = try await actorgetProfile(actor: NetworkManager.shared.handle)
    } catch {
    }
  }
  var body: some View {
    NavigationSplitView {
      List(selection: $selection) {
        HStack(spacing: 5) {
          if let avatar = self.profile.avatar {
            AvatarView(url: URL(string: avatar)!, size: 40)
          } else {
            Image(systemName: "person.crop.circle.fill")
              .resizable()
              .foregroundStyle(.white, Color.accentColor)
              .frame(width: 40, height: 40)
              .cornerRadius(20)
          }
          VStack(alignment: .leading, spacing: 0) {
            if let displayname = self.profile.displayName {
              Text(displayname)
            }
            Text(self.profile.handle)
              .font(.footnote)
              .opacity(0.6)
          }
        }.tag(0)
        Section {
          Label("Home", systemImage: "house")
            .tag(1)
          Label("Popular", systemImage: "arrow.up.right.circle.fill")
            .tag(2)
        }
      }
      .frame(minWidth: 230)
      .listStyle(.sidebar)
    } detail: {
      NavigationStack(path: $path) {
        Group {
          switch selection {
          case 0:
            ProfileView(did: profile.did, profile: profile, path: $path)
              .frame(minWidth: 800)
              .navigationTitle(profile.handle)
          case 1:
            HomeView(path: $path)
              .frame(minWidth: 800)
              .navigationTitle("Home")
          case 2:
            PopularView(path: $path)
              .frame(minWidth: 800)
              .navigationTitle("Popular")
          default:
            EmptyView()
          }
        }
        .navigationDestination(for: FeedDefsFeedViewPost.self) { post in
          ThreadView(uri: post.post.uri, compose: $replypost, post: $post, path: $path)
            .frame(minWidth: 800)
        }
        .navigationDestination(for: FeedDefsPostView.self) { post in
          ThreadView(uri: post.uri, compose: $replypost, post: $post, path: $path)
            .frame(minWidth: 800)
        }
        .navigationDestination(for: EmbedRecordViewRecord.self) { post in
          ThreadView(uri: post.uri, compose: $replypost, post: $post, path: $path)
            .frame(minWidth: 800)
        }
        .navigationDestination(for: ActorDefsProfileViewBasic.self) { actorref in
          ProfileView(did: actorref.did, path: $path)
            .frame(minWidth: 800)
        }
        .navigationDestination(for: ProfileRouter.self) { router in
          switch router {
          case let .followers(handle):
            FollowersView(handle: handle, path: $path)
              .frame(minWidth: 800)
              .navigationTitle("People following @\(handle)")
          case let .following(handle):
            FollowsView(handle: handle, path: $path)
              .frame(minWidth: 800)
              .navigationTitle("People followed by @\(handle)")
          }
        }
        .toolbar {
          ToolbarItem(placement: .primaryAction) {
            Button {
              compose = true
            } label: {
              Image(systemName: "square.and.pencil")
            }
            .sheet(isPresented: $compose) {
              NewPostView(isPresented: $compose)
                .frame(minWidth: 600, maxWidth: 600, minHeight: 300, maxHeight: 300)
            }
          }
          ToolbarItem {
            SearchField { search in
              if !search.isEmpty {
                do {
                  self.searchactors = try await ActorSearchActorsTypeahead(term: search)
                  self.searchpresented = !self.searchactors.actors.isEmpty
                } catch {

                }
              }
              else {
                self.searchactors = .init()
                self.searchpresented = false
              }
              
            }
            .frame(width: 150)
            .popover(isPresented: $searchpresented, arrowEdge: .bottom) {
              SearchActorView(actorstypeahead: self.$searchactors, path: self.$path)
            }
          }
        }
      }
    }
    .handlesExternalEvents(preferring: ["*"], allowing: ["*"])
    .onOpenURL(perform: { url in
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
      let did = components?.queryItems?.first { $0.name == "did" }?.value
      guard let did = did else {
          return
      }
   
      path.append(ActorDefsProfileViewBasic(avatar: nil, did: did, displayName: "", handle: ""))
    })
    .sheet(isPresented: $replypost) {
      ReplyView(isPresented: $replypost, viewpost: $post)
        .frame(minWidth: 600, maxWidth: 600, minHeight: 400, maxHeight: 800)
    }
    .onChange(of: auth.needAuthorization) { newValue in
      if !newValue {
        Task {
          await loadProfile()
        }
      }
    }
    .task {
      selection = 1
      if !auth.needAuthorization {
        await loadProfile()
      }
    }
  }
}
