//
//  PostView.swift
//  swiftsky
//

import SwiftUI
import QuickLook

struct PostView: View {
    @State var post: FeedPostView
    @State var reply: FeedFeedViewPostReplyRef?
    @State var lockupvote: Bool = false
    @State var usernamehover: Bool = false
    @State var repost: FeedFeedViewPostReason? = nil
    @State var previewurl: URL? = nil
    @Binding var path: NavigationPath
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
    
                    Button {
                        path.append(post.author)
                    } label: {
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
                    .menuStyle(.button)
                    .buttonStyle(.plain)
                    .menuIndicator(.hidden)
                }
                if let reply = reply {
                    Text("Reply to @\(reply.parent.author.handle)").foregroundColor(.secondary)
                }
                if !post.record.text.isEmpty {
                    Text(post.record.text)
                        .foregroundColor(.primary)
                        .textSelection(.enabled)
                        .if(post.embed?.images == nil) { view in
                            view.padding(.bottom, 6)
                        }
                        //.padding(.bottom, 8)
                }
                if let embed = post.embed {
                    if let images = embed.images {
                        HStack {
                            ForEach(images, id: \.self) { image in
                                Button {
                                    previewurl = URL(string: image.fullsize)

                                } label: {
                                    CachedAsyncImage(url: URL(string: image.thumb)) { image in
                                        image
                                            .resizable()
                                    } placeholder: {
                                        Image(systemName: "photo.fill")
                                    }
                                    .frame(width: 600 / CGFloat(images.count), height: 600 / CGFloat(images.count))
                                    .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                                    .cornerRadius(15)
                                }.buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .quickLookPreview($previewurl)
    }
}
