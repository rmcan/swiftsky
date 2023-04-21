//
//  SidebarView.swift
//  swiftsky
//

import SwiftUI

struct SidebarView: View {
  @StateObject private var auth = Auth.shared
  @StateObject private var globalmodel = GlobalViewModel.shared
  @State private var selection: Int = -1
  @State private var path = NavigationPath()
  @State var compose: Bool = false
  @State var replypost: Bool = false
  @State private var post: FeedDefsPostView? = nil
  @State var searchactors = ActorSearchActorsTypeaheadOutput()
  @State var searchpresented = false
  func loadProfile() async {
    do {
      self.globalmodel.profile = try await actorgetProfile(actor: NetworkManager.shared.handle)
    } catch {
      
    }
  }
  var body: some View {
    NavigationSplitView {
      List(selection: $selection) {
        HStack(spacing: 5) {
          AvatarView(url: self.globalmodel.profile.avatar, size: 40)
          VStack(alignment: .leading, spacing: 0) {
            if let displayname = self.globalmodel.profile.displayName {
              Text(displayname)
            }
            Text(self.globalmodel.profile.handle)
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
            ProfileView(did: self.globalmodel.profile.did, profile: self.globalmodel.profile, path: $path)
              .frame(minWidth: 800)
              .navigationTitle(self.globalmodel.profile.handle)
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
          ThreadView(uri: post.post.uri, path: $path)
            .frame(minWidth: 800)
        }
        .navigationDestination(for: FeedDefsPostView.self) { post in
          ThreadView(uri: post.uri, path: $path)
            .frame(minWidth: 800)
        }
        .navigationDestination(for: EmbedRecordViewRecord.self) { post in
          ThreadView(uri: post.uri, path: $path)
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
              NewPostView()
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
              SearchActorView(actorstypeahead: self.$searchactors) { user in
                path.append(user)
              }
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
