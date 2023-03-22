//
//  ThreadView.swift
//  swiftsky
//

import SwiftUI

struct ReplyView: View {
    @Binding var isPresented: Bool
    @State var viewpost: FeedPostView
    @State var reply = ""
    var body: some View {
        VStack {
            HStack() {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.plain)
                .padding([.leading, .top], 20)
                .foregroundColor(.accentColor)
                Spacer()
                Button("Reply") { }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                .disabled(reply.count > 256)
                .padding([.trailing, .top], 20)
            }
            Divider().padding(.vertical, 5)
            HStack(alignment: .top, spacing: 12) {
                if let avatar = viewpost.author.avatar {
                    AvatarView(url: URL(string: avatar)!, size: 50)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(.accentColor)
                        .frame(width: 50, height: 50)
                        .cornerRadius(20)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewpost.author.displayName ?? viewpost.author.handle)
                        .fontWeight(.semibold)
                    Text(viewpost.record.text)
                }
                Spacer()
            }
            .padding(.leading, 20)
            Divider()
                .padding(.vertical, 5)
            HStack(alignment: .top) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(.accentColor)
                    .frame(width: 50, height: 50)
                    .cornerRadius(20)
                
                ZStack(alignment: .leading) {
                    if reply.isEmpty {
                       VStack {
                           Text("Reply to @\(viewpost.author.handle)")
                                .padding(.leading, 6)
                                .opacity(0.7)
                            Spacer()
                        }
                    }
                    
                    VStack {
                        TextEditor(text: $reply)
                        Spacer()
                    }
                }
                .scrollContentBackground(.hidden)
                .font(.system(size: 20))
                Spacer()
            }
            .padding([.leading], 20)
            Divider()
                .padding(.vertical, 5)
            HStack {
                Spacer()
                let replycount = 256 - reply.count
                Text("\(replycount)")
                    .padding(.trailing, 20)
                    .foregroundColor(replycount < 0 ? .red : .primary)
                    
            }
            Spacer()
        }
    }
}
struct SeparatorShape: Shape {
    var yoffset = 0.0
    var lastpost = false
    func path(in rect: CGRect) -> Path {
        var path = Path()
        if lastpost {
            path.addRect(CGRect(x: rect.minX + 35, y: rect.minY + yoffset, width: 2, height: rect.maxY + 15))
        }
        else {
            path.addRect(CGRect(x: rect.minX + 35, y: rect.minY + yoffset, width: 2, height: rect.maxY - yoffset))
        }
        return path
    }
}
struct ThreadView: View {
    var uri: String
    @State var threadviewpost: FeedGetPostThreadThreadViewPost? = nil
    @State var parents: [FeedGetPostThreadThreadViewPost] = []
    @State var compose: Bool = false
    @Binding var path: NavigationPath
    var body: some View {
        List {
            Group {
                if let viewpost = threadviewpost?.post {
                    ForEach(parents) { parent in
                        ZStack {
                            SeparatorShape(yoffset: parent == parents.first ? 55 : 0, lastpost: parent == parents.last)
                                .foregroundColor(Color(nsColor: NSColor.quaternaryLabelColor))
                            VStack(spacing: 0) {
                                PostView(post: parent.post, reply: parent.parent?.post.author.handle, path: $path)
                                    .padding([.top,.horizontal])
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        path.append(parent.post)
                                    }
                                PostFooterView(bottompadding: false, post: parent.post)
                                    .padding(.leading, 67.0)
                            }
                        }
                    }
                    ThreadPostview(post: viewpost,reply: threadviewpost?.parent?.post.author.handle, path: $path)
                        .padding([.top, .horizontal])
                    PostFooterView(post: viewpost)
                        .padding(.leading, 17.0)
                    Divider()
                    HStack() {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.accentColor)
                            .frame(width: 40, height: 40)
                            .padding(.leading)
                            .padding([.vertical, .trailing], 5)
                        
                        Text("Reply to @\(viewpost.author.handle)")
                            .font(.system(size: 15))
                            .opacity(0.9)
                        Spacer()
                    }.onHover { ishovered in
                        if ishovered {
                            NSCursor.pointingHand.push()
                        }
                        else {
                            NSCursor.pointingHand.pop()
                        }
                    }.onTapGesture {
                        compose = true
                    }
                    .sheet(isPresented: $compose) {
                        ReplyView(isPresented: $compose, viewpost: viewpost)
                            .frame(minWidth: 600, maxWidth: 600, minHeight: 400, maxHeight: 800)
                    }
                    Divider()
                    if let replies = threadviewpost?.replies {
                        ForEach(replies, id: \.self) { post in
                            HStack {
                                PostView(post: post.post,reply: viewpost.author.handle, path: $path)
                                    .padding([.top, .horizontal])
                                    .contentShape(Rectangle())
                            }
                            .onTapGesture {
                                path.append(post.post)
                            }
                            PostFooterView(post: post.post)
                                .padding(.leading, 67.0)
                            Divider()
                        }
                    }
                } else {
                    ProgressView().frame(maxWidth: .infinity, alignment: .center)
                }
            }.listRowInsets(EdgeInsets())
        }
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListRowHeight, 0.1)
        .listStyle(.plain)
        .navigationTitle(threadviewpost != nil ? "\(threadviewpost!.post.author.handle)'s post" : "Loading post...")
        .onAppear {
            getPostThread(uri: self.uri) { result in
                if let result = result {
                    if let thread = result.thread {
                        self.threadviewpost = thread
                        var currentparent = thread.parent
                        while let parent = currentparent {
                            parents.append(parent)
                            currentparent = parent.parent
                        }
                        parents.reverse()
                    }
                }
            }
        }
    }
}

