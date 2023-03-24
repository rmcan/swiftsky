//
//  ProfileView.swift
//  swiftsky
//

import SwiftUI
import QuickLook

struct ProfileView: View {
    var handle: String
    @State var profile: ActorProfileView?
    @State var authorfeed = FeedGetAuthorFeedOutput()
    @State var previewurl: URL?
    @State private var disablefollowbutton = false
    @Binding var path: NavigationPath
    var body: some View {
        List {
            if let profile = profile {
                VStack(alignment: .leading)  {
                    ZStack(alignment: .bottomLeading) {
                        if let banner = profile.banner {
                            CachedAsyncImage(url: URL(string: banner)){ image in
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
                        }
                        else {
                            Color(.controlAccentColor)
                                .frame(height: 200)
                        }
                        if let avatar = profile.avatar {
                            AvatarView(url: URL(string: avatar)!, size: 80)
                                .offset(x: 20, y: 40)
                                .onTapGesture {
                                    previewurl = URL(string: avatar)
                                }
                        }
                        else {
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
                                            let result = try await RepoDeleteRecord(uri: following, collection: "app.bsky.graph.follow")
                                            if result {
                                                self.profile?.viewer?.following = nil
                                            }
                                        } catch {
                                            
                                        }
                                        disablefollowbutton = false
                                    }
                                }
                                .disabled(disablefollowbutton)
                            }
                            else {
                                Button("\(Image(systemName: "plus")) Follow") {
                                    disablefollowbutton = true
                                    Task {
                                        do {
                                            let result = try await followUser(did: profile.did, declarationCid: profile.declaration.cid)
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
                            Text("\(profile.followersCount) \(Text("followers").foregroundColor(.secondary))")
                            Text("\(profile.followsCount) \(Text("following").foregroundColor(.secondary))")
                            Text("\(profile.postsCount) \(Text("posts").foregroundColor(.secondary))")
                        }
                        .padding(.bottom, -5)
                        if let description = profile.description {
                            Text(description).textSelection(.enabled)
                        }
                    }
                    .textSelection(.enabled)
                    .padding(.top, 5)
                    .padding(.leading, 20)
                    Divider()
                }
                ForEach(authorfeed.feed) { post in
                    Group {
                        PostView(post: post.post, reply: post.reply?.parent.author.handle, repost: post.reason, path: $path)
                            .padding([.top, .horizontal])
                            .contentShape(Rectangle())
                            .onTapGesture {
                                path.append(post)
                            }
                            .onAppear {
                                if post == authorfeed.feed.last {
                                    if let cursor = self.authorfeed.cursor {
                                        Task {
                                            do {
                                                let result = try await getAuthorFeed(author: profile.handle, before: cursor)
                                                self.authorfeed.feed.append(contentsOf: result.feed)
                                                self.authorfeed.cursor = result.cursor
                                            } catch {
                                                
                                            }
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
        .environment(\.defaultMinListRowHeight, 0.1)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .onAppear {
            Task {
                do {
                    self.profile = try await getProfile(actor: handle)
                    self.authorfeed = try await getAuthorFeed(author: handle)
                } catch {
                    
                }
            }
        }
        .quickLookPreview($previewurl)
    }
}
