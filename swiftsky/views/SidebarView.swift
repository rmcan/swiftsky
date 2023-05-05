//
//  SidebarView.swift
//  swiftsky
//

import SwiftUI

struct SidebarView: View {
  @EnvironmentObject private var auth: Auth
  @EnvironmentObject private var globalviewmodel: GlobalViewModel
  @EnvironmentObject private var pushnotifications: PushNotificatios
  @State private var selection: Int = -1
  @State private var path = NavigationPath()
  @State var compose: Bool = false
  @State var replypost: Bool = false
  @State private var post: FeedDefsPostView? = nil
  @State var searchactors = ActorSearchActorsTypeaheadOutput()
  @State var searchpresented = false
  var body: some View {
    NavigationSplitView {
      List(selection: $selection) {
        HStack(spacing: 5) {
          AvatarView(url: self.globalviewmodel.profile?.avatar, size: 40)
          VStack(alignment: .leading, spacing: 0) {
            if auth.needAuthorization || self.globalviewmodel.profile == nil {
              Text("Sign in")
            }
            else {
              if let displayname = self.globalviewmodel.profile!.displayName {
                Text(displayname)
              }
              Text(self.globalviewmodel.profile!.handle)
                .font(.footnote)
                .opacity(0.6)
            }
            
          }
        }.tag(0)
        Section {
          Label("Home", systemImage: "house")
            .tag(1)
          Label("Popular", systemImage: "arrow.up.right.circle.fill")
            .tag(2)
          Label("Notifications", systemImage: "bell.badge")
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(alignment: .trailing) {
              let unreadcount = pushnotifications.unreadcount
              if unreadcount > 0 {
                Circle().fill(.red)
                  .overlay {
                    Text("\(unreadcount < 10 ? "\(unreadcount)" : "9+")")
                      .font(.system(size: 11))
                  }
              }
             
            }
            .tag(3)
        }
      }
      .frame(minWidth: 230)
      .listStyle(.sidebar)
    } detail: {
      NavigationStack(path: $path) {
        Group {
          switch selection {
          case 0:
            if let profile = self.globalviewmodel.profile {
              ProfileView(did: profile.did, profile: profile, path: $path)
                .frame(minWidth: 800)
                .navigationTitle(profile.handle)
            }
            else {
              EmptyView()
            }
         
          case 1:
            HomeView(path: $path)
              .frame(minWidth: 800)
              .navigationTitle("Home")
          case 2:
            PopularView(path: $path)
              .frame(minWidth: 800)
              .navigationTitle("Popular")
          case 3:
            NotificationsView()
              .frame(minWidth: 800)
              .navigationTitle("Notifications")
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
        .navigationDestination(for: ActorDefsProfileView.self) { actorref in
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
    .task {
      selection = 1
      if !auth.needAuthorization {
        self.globalviewmodel.profile = try? await actorgetProfile(actor: Client.shared.handle)
      }
    }
  }
}
