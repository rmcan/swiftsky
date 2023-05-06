//
//  NewPostView.swift
//  swiftsky
//

import SwiftUI

struct NewPostView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var text = ""
  @State private var disablebuttons: Bool = false
  @State private var error: String?
  @StateObject private var globalmodel = GlobalViewModel.shared
  var post: FeedDefsPostView? = nil
  var isquote: Bool = false
  func makepost() {
    disablebuttons = true
    Task {
      do {
        var replyref: FeedPostReplyRef? = nil
        if !isquote, let post {
          let parent = RepoStrongRef(cid: post.cid, uri: post.uri)
          let root = post.record.reply != nil ? RepoStrongRef(cid: post.record.reply!.root.cid, uri: post.record.reply!.root.uri) : parent
          replyref = FeedPostReplyRef(parent: parent, root: root)
        }
        let rt = RichText(text: text, facets: nil)
        let facets = await rt.detectFacets()
        let _ = try await makePost(text: text, reply: replyref, facets: facets, embed: isquote ? EmbedRef(cid: post!.cid, uri: post!.uri) : nil)
        dismiss()
      } catch {
        self.error = error.localizedDescription
      }
      disablebuttons = false
    }
  }
  var body: some View {
    VStack {
      HStack {
        Button("Cancel") {
          dismiss()
        }
        .buttonStyle(.plain)
        .padding([.leading, .top], 20)
        .foregroundColor(.accentColor)
        .disabled(disablebuttons)
        Spacer()
        Button("Post") {
          makepost()
        }
        .buttonStyle(.borderedProminent)
        .tint(.accentColor)
        .disabled(text.count > 300 || disablebuttons)
        .padding([.trailing, .top], 20)
      }
      if let post {
        Divider().padding(.vertical, 5)
        HStack(alignment: .top, spacing: 12) {
          AvatarView(url: post.author.avatar, size: 40)
          VStack(alignment: .leading, spacing: 2) {
            Text(post.author.displayName ?? post.author.handle)
              .fontWeight(.semibold)
            Text(post.record.text)
          }
          Spacer()
        }
        .padding(.leading, 20)
      }
      Divider()
        .padding(.vertical, 5)
      HStack(alignment: .top) {
        AvatarView(url: globalmodel.profile?.avatar, size: 50)
        let placeholder = post != nil && !isquote ? "Reply to @\(post!.author.handle)" : "What's up?"
        TextViewWrapper(text: $text, placeholder: placeholder)
        Spacer()
      }
      .padding([.leading], 20)
      Divider()
        .padding(.vertical, 5)
      HStack {
        Spacer()
        let replycount = 300 - text.count
        Text("\(replycount)")
          .padding(.trailing, 20)
          .foregroundColor(replycount < 0 ? .red : .primary)
      }
      Spacer()
    }
    .alert("Error: \(self.error ?? "Unknown")", isPresented: .constant(error != nil)) {
      Button("OK") {
        error = nil
      }
    }
  }
}
