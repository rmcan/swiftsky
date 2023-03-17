//
//  PostView.swift
//  swiftsky
//

import SwiftUI

struct PostView: View {
    @State var post: FeedPostView
    @State var reply: FeedFeedViewPostReplyRef?
    @State var lockupvote: Bool = false
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
                HStack(alignment: .firstTextBaseline) {
                    if let displayname = post.author.displayName {
                        Text(displayname)
                            .fontWeight(.semibold)
                    }
                    else {
                        Text(post.author.handle)
                            .fontWeight(.semibold)
                    }
                    
                    
                    Text(post.author.handle)
                        .foregroundColor(.secondary)
                    
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
                Text(post.record.text)
                    .foregroundColor(.primary)
                    .textSelection(.enabled)
                    .padding(.bottom, 8)
                
            }
        
        }
    }
}
