//
//  ThreadPostView.swift
//  swiftsky
//

import SwiftUI
import QuickLook

struct ThreadPostview: View {
    @State var post: FeedPostView
    @State var reply: String?
    @State var usernamehover: Bool = false
    @State var displaynamehover: Bool = false
    @State var previewurl: URL? = nil
    @State var deletepostfailed = false
    @State var deletepost = false
    @Binding var path: NavigationPath
    var load: () -> ()
    func delete() {
        deletePost(uri: post.uri) { result in
            if result {
                load()
            }
            else {
                deletepostfailed = true
            }
        }
    }
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                if let avatar = post.author.avatar {
                    AvatarView(url: URL(string: avatar)!, size: 40)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(.accentColor)
                        .frame(width: 40, height: 40)
                        .cornerRadius(20)
                }
                HStack(alignment: .firstTextBaseline) {
                    let displayname = post.author.displayName ?? post.author.handle
                    VStack(alignment: .leading) {
                        Button {
                            path.append(post.author)
                        } label: {
                            Text(displayname)
                                .fontWeight(.semibold)
                                .underline(usernamehover)
                        }
                        .buttonStyle(.plain)
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
                        Button {
                            path.append(post.author)
                        } label: {
                            Text("@\(post.author.handle)")
                                .foregroundColor(.secondary)
                                .fontWeight(.semibold)
                                .underline(displaynamehover)
                        }
                        .buttonStyle(.plain)
                        .onHover{ ishovered in
                            if ishovered {
                                displaynamehover = true
                                NSCursor.pointingHand.push()
                            }
                            else {
                                displaynamehover = false
                                NSCursor.pointingHand.pop()
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Group {
                        MenuButton {
                            var items: [MenuItem] = []
                            items.append(MenuItem(title: "Share") {
                                print("Share")
                            })
                            items.append(MenuItem(title: "Report") {
                                print("Report")
                            })
                            if post.author.did == api.shared.did {
                                items.append(MenuItem(title: "Delete") {
                                    deletepost = true
                                })
                            }
                            return items
                        }
                        .frame(width: 30, height: 30)
                        .contentShape(Rectangle())
                        .onHover{ ishovered in
                            if ishovered {
                                NSCursor.pointingHand.push()
                            }
                            else {
                                NSCursor.pointingHand.pop()
                            }
                        }
                    }
                }
            }
            
            if !post.record.text.isEmpty {
                Text(post.record.text)
                    .foregroundColor(.primary)
                    .textSelection(.enabled)
                    .padding(.vertical, 4)
            }
            if let embed = post.embed {
                if let record: EmbedRecordPresentedRecord = embed.record {
                    Button {
                        path.append(record)
                    } label: {
                        EmbedPostView(embedrecord: record, path: $path)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                }
                if let images = embed.images {
                    HStack {
                        ForEach(images, id: \.self) { image in
                            Button {
                                previewurl = URL(string: image.fullsize)
                                
                            } label: {
                                let imagewidth = 600.0 / Double(images.count)
                                let imageheight = 600.0 / Double(images.count)
                                CachedAsyncImage(url: URL(string: image.thumb)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: imagewidth, height: imageheight)
                                        .contentShape(Rectangle())
                                        .clipped()
                                    
                                } placeholder: {
                                    ProgressView()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                                .frame(width: imagewidth, height: imageheight)
                                .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                                .cornerRadius(15)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            Text("\(Text(post.record.createdAt, style: .time)) · \(Text(post.record.createdAt, style: .date))")
                .foregroundColor(.secondary)
                .padding(.bottom, 6)
        }
        .quickLookPreview($previewurl)
        .alert("Failed to delete post, please try again.", isPresented: $deletepostfailed, actions: {})
        .alert("Are you sure?",isPresented: $deletepost) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                self.delete()
            }
        }
    }
}
