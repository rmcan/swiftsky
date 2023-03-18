//
//  SidebarView.swift
//  swiftsky
//

import SwiftUI

struct SidebarView: View {
    @State var profile: ActorProfileView = ActorProfileView()
    @StateObject private var auth = Auth.shared
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ProfileView(handle: profile.handle, profile: profile)) {
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
                Spacer()
                NavigationLink(destination: HomeView()) {
                    Label("Home", systemImage: "house")
                }.frame(alignment: .top)
                
            }
            .listStyle(SidebarListStyle())
            .navigationTitle("Explore")
            .frame(width: 200)
            .toolbar{
                ToolbarItem(placement: .navigation){
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.left")
                    })
                }
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
