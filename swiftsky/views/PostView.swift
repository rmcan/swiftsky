//
//  PostView.swift
//  swiftsky
//

import SwiftUI

struct PostView: View {
    @State var post: FeedPostView
    @State var reply: FeedFeedViewPostReplyRef?
    @State var lockupvote: Bool = false
    @State var usernamehover: Bool = false
    @State var repost: FeedFeedViewPostReason? = nil
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let avatar = post.author.avatar {
                AvatarView(url: URL(string: avatar)!, size: 40)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(.accentColor)
                    .frame(width: 40, height: 40)
                    .cornerRadius(20)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                if let repost = repost {
                    Text("\(Image(systemName: "arrow.triangle.2.circlepath")) Reposted by \(repost.by.handle)")
                        .foregroundColor(.secondary)
                }
                HStack(alignment: .firstTextBaseline) {
                    let displayname = post.author.displayName ?? post.author.handle
    
                    NavigationLink(destination: ProfileView(handle: post.author.handle).navigationTitle(post.author.handle)) {
                        Text("\(displayname) \(Text(post.author.handle).foregroundColor(.secondary))")
                            .fontWeight(.semibold)
                            .underline(usernamehover)
                    }
                    .onHover{ ishovered in
                        if ishovered {
                            usernamehover = true
                            NSCursor.pointingHand.push()
                        }
                        else {
                            usernamehover = false
                            NSCursor.pointingHand.pop()
                        }
                    }
                    .buttonStyle(.plain)
                   
                    Text(dateformatter.localizedString(fromTimeInterval: post.record.createdAt.timeIntervalSinceNow))
                        .font(.body)
                        .foregroundColor(.secondary)

                    Spacer()
                    Menu {
                        Button("Share") { }
                        Button("Report post") { }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                    .menuStyle(ButtonMenuStyle())
                    .buttonStyle(BorderlessButtonStyle())
                    .menuIndicator(.hidden)
                }
                if let reply = reply {
                    Text("Reply to @\(reply.parent.author.handle)").foregroundColor(.secondary)
                }
                if !post.record.text.isEmpty {
                    Text(post.record.text)
                        .foregroundColor(.primary)
                        .textSelection(.enabled)
                        .padding(.bottom, 8)
                }
            }
        }
    }
}
