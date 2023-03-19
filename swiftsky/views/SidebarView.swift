//
//  SidebarView.swift
//  swiftsky
//

import SwiftUI

struct SidebarView: View {
    @State var profile: ActorProfileView = ActorProfileView()
    @StateObject private var auth = Auth.shared
    @State private var selection: Int = 1
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section {
                    NavigationLink(value: 0) {
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
                        }
                    }
                }
                Section {
                    NavigationLink(value: 1) {
                        Label("Home", systemImage: "house")
                    }
                }
            }
            .frame(minWidth: 230)
            .listStyle(.sidebar)
        } detail: {
            switch selection {
            case 0:
                ProfileView(handle: profile.handle, profile: profile).frame(minWidth: 800)
            case 1:
                HomeView().frame(minWidth: 800)
            default:
                HomeView().frame(minWidth: 800)
            }
        }
        .onChange(of: auth.needAuthorization) {newValue in
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
