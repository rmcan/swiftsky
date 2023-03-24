//
//  ReplyView.swift
//  swiftsky
//

import SwiftUI

struct ReplyView: View {
    @Binding var isPresented: Bool
    @Binding var viewpost: FeedPostView?
    @State var reply = ""
    @State var disablebuttons: Bool = false
    @State var erroralert: Bool = false
    func replyPost() {
        disablebuttons = true
        Task {
            do {
                let _ = try await makePost(text: reply)
                isPresented = false
            } catch {
                erroralert = true
            }
            disablebuttons = false
        }
    }
    var body: some View {
        VStack {
            HStack() {
                Button("Cancel") {
                    isPresented = false
                }
                .buttonStyle(.plain)
                .padding([.leading, .top], 20)
                .foregroundColor(.accentColor)
                .disabled(disablebuttons)
                Spacer()
                Button("Reply") {
                    replyPost()
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                .disabled(reply.count > 256 || disablebuttons)
                .padding([.trailing, .top], 20)
            }
            if let viewpost = viewpost {
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
            }
    
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
                           Text(viewpost != nil ? "Reply to @\(viewpost!.author.handle)" : "Write your reply")
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
        .alert("Failed to reply post, please try again", isPresented: $erroralert, actions: {})
    }
}
