//
//  FollowersView.swift
//  swiftsky
//

import SwiftUI

private struct FollowersRowView: View {
  @State var user: ActorRefWithInfo
  @State var usernamehover: Bool = false
  @State var followingdisabled: Bool = false
  @Binding var path: NavigationPath
  func follow() {
    followingdisabled = true
    Task {
      do {
        let result = try await followUser(
          did: user.did, declarationCid: user.declaration.cid)
        self.user.viewer?.following = result.uri
      } catch {
        print(error)
      }
      followingdisabled = false
    }
  }
  func unfollow() {
    followingdisabled = true
    Task {
      do {
        let result = try await repoDeleteRecord(
          uri: user.viewer!.following!, collection: "app.bsky.graph.follow")
        if result {
          self.user.viewer!.following = nil
        }
      } catch {
        print(error)
      }
      followingdisabled = false
    }
  }
  var body: some View {
    HStack(alignment: .top) {
      if let avatar = user.avatar {
        AvatarView(url: URL(string: avatar)!, size: 40)
      } else {
        Image(systemName: "person.crop.circle.fill")
          .resizable()
          .foregroundColor(.accentColor)
          .frame(width: 40, height: 40)
          .cornerRadius(20)
      }
      let displayname = user.displayName ?? user.handle
      VStack(alignment: .leading, spacing: 0) {
        Group {
          Text(displayname)
            .underline(usernamehover)
            .onHover { hover in
              usernamehover = hover
              if hover {
                NSCursor.pointingHand.push()
              } else {
                NSCursor.pointingHand.pop()
              }
            }
          Text("@\(user.handle)").foregroundColor(.secondary)
        }
        .onTapGesture {
          path.append(user)
        }
        if user.viewer?.followedBy != nil {
          ZStack {
            RoundedRectangle(cornerRadius: 10)
              .opacity(0.04)
            Text("Follows you")
          }.padding(.top, 2)
          .frame(maxWidth: 90)
        }
      }
      Spacer()
      if user.did != NetworkManager.shared.did {
        let following = user.viewer?.following != nil
        Button {
          following ? unfollow() : follow()
        } label: {
          Group {
            if !following {
              Text("\(Image(systemName: "plus")) Follow")
            }
            else {
              Text("Unfollow")
            }
          }.frame(maxWidth: 60)
        }
        .disabled(followingdisabled)
        .buttonStyle(.borderedProminent)
        .tint(!following ? .accentColor : Color(.controlColor))
        .padding(.trailing, 2)
        .frame(maxHeight: .infinity, alignment: .center)
      }
    }
  }
}
struct FollowersView: View {
  let handle: String
  @State var followers: graphGetFollowersOutput? = nil
  @Binding var path: NavigationPath
  func getFollowers() {
    Task {
      do {
        self.followers = try await graphGetFollowers(user: handle)
      } catch {
        
      }
    }
  }
  func getMoreFollowers(cursor: String) {
    Task {
      do {
        let result = try await graphGetFollowers(user: handle, before: cursor)
        self.followers!.cursor = result.cursor
        self.followers!.followers.append(contentsOf: result.followers)
      } catch {
        
      }
    }
  }
  var body: some View {
    List {
      if let followers {
        ForEach(followers.followers) { user in
          FollowersRowView(user: user, path: $path)
            .padding(5)
            .onAppear {
              if user == followers.followers.last {
                if let cursor = followers.cursor {
                  getMoreFollowers(cursor: cursor)
                }
              }
            }
          Divider()
        }
        .listRowInsets(EdgeInsets())
        if followers.cursor != nil {
          ProgressView()
            .frame(maxWidth: .infinity, alignment: .center)
        }
  
      }
    }
    .environment(\.defaultMinListRowHeight, 0.1)
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
    .onAppear {
      getFollowers()
    }
  }
}
