//
//  SidebarView.swift
//  swiftsky
//

import SwiftUI

struct SidebarView: View {
    @State var profile: ActorProfileView = ActorProfileView()
    @StateObject private var auth = Auth.shared
    @State private var selection: Int = 1
    @State private var path = NavigationPath()
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                HStack (spacing: 5) {
                    if let avatar = self.profile.avatar {
                        AvatarView(url: URL(string: avatar)!, size: 40)
                    }
                    else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.accentColor)
                            .frame(width: 40, height: 40)
                            .cornerRadius(20)
                    }
                    VStack(alignment: .leading, spacing: 0)  {
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
                        ProfileView(handle: profile.handle, profile: profile, path: $path)
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
                        HomeView(path: $path)
                            .frame(minWidth: 800)
                            .navigationTitle("Home")
                    }
                }
                .navigationDestination(for: FeedFeedViewPost.self) { post in
                    ThreadView(uri: post.post.uri, path: $path)
                }
                .navigationDestination(for: FeedPostView.self) { post in
                    ThreadView(uri: post.uri, path: $path)
                }
                .navigationDestination(for: EmbedRecordPresentedRecord.self) { post in
                    ThreadView(uri: post.uri, path: $path)
                }
                .navigationDestination(for: ActorRefWithInfo.self) { actorref in
                    ProfileView(handle: actorref.handle, path: $path)
                        .navigationTitle(actorref.handle)
                }
               
            }
        }
        .onChange(of: auth.needAuthorization) { newValue in
            if !newValue {
                getProfile(actor: api.shared.handle) { result in
                    if let result = result {
                        self.profile = result
                    }
                }
            }
        }
        .onAppear {
            if !auth.needAuthorization {
                getProfile(actor: api.shared.handle) { result in
                    if let result = result {
                        self.profile = result
                    }
                }
            }
        }
    }
}

func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}
