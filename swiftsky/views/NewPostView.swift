//
//  NewPostView.swift
//  swiftsky
//

import SwiftUI

struct NewPostView: View {
  @Environment(\.dismiss) private var dismiss
  @State var text = ""
  @State var disablebuttons: Bool = false
  @State var error: String?
  @StateObject private var globalmodel = GlobalViewModel.shared
  var replypost: FeedDefsPostView? = nil
  func post() {
    disablebuttons = true
    Task {
      do {
        var replyref: FeedPostReplyRef? = nil
        if let replypost {
          let parent = RepoStrongRef(cid: replypost.cid, uri: replypost.uri)
          let root = replypost.record.reply != nil ? RepoStrongRef(cid: replypost.record.reply!.root.cid, uri: replypost.record.reply!.root.uri) : parent
          replyref = FeedPostReplyRef(parent: parent, root: root)
        }
        let rt = RichText(text: text, facets: nil)
        let facets = await rt.detectFacets()
        let _ = try await makePost(text: text,reply: replyref, facets: facets)
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
          post()
        }
        .buttonStyle(.borderedProminent)
        .tint(.accentColor)
        .disabled(text.count > 300 || disablebuttons)
        .padding([.trailing, .top], 20)
      }
      if let replypost {
        Divider().padding(.vertical, 5)
        HStack(alignment: .top, spacing: 12) {
          AvatarView(url: replypost.author.avatar, size: 40)
          VStack(alignment: .leading, spacing: 2) {
            Text(replypost.author.displayName ?? replypost.author.handle)
              .fontWeight(.semibold)
            Text(replypost.record.text)
          }
          Spacer()
        }
        .padding(.leading, 20)
      }
      Divider()
        .padding(.vertical, 5)
      HStack(alignment: .top) {
        AvatarView(url: globalmodel.profile?.avatar, size: 50)
        let placeholder = replypost != nil ? "Reply to @\(replypost!.author.handle)" : "What's up?"
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
