//
//  NewPostView.swift
//  swiftsky
//

import SwiftUI

struct ImageAttachment: Identifiable {
  let id = UUID()
  let image: Image
  let data: Data
}
struct NewPostView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var text = ""
  @State private var disablebuttons: Bool = false
  @State private var error: String?
  @State private var images: [ImageAttachment] = []
  @StateObject private var globalmodel = GlobalViewModel.shared
  var post: FeedDefsPostView? = nil
  var isquote: Bool = false
  func makepost() {
    disablebuttons = true
    Task {
      do {
        var images: [EmbedImagesImage] = []
        for image in self.images {
          let result = try await repouploadBlob(data: image.data)
          images.append(.init(alt: "", image: result.blob))
        }
        let embed = EmbedRef(record: isquote ? .init(cid: post!.cid, uri: post!.uri) : nil, images: !images.isEmpty ? .init(images: images) : nil)
        var replyref: FeedPostReplyRef? = nil
        if !isquote, let post {
          let parent = RepoStrongRef(cid: post.cid, uri: post.uri)
          let root = post.record.reply != nil ? RepoStrongRef(cid: post.record.reply!.root.cid, uri: post.record.reply!.root.uri) : parent
          replyref = FeedPostReplyRef(parent: parent, root: root)
        }
        let rt = RichText(text: text, facets: nil)
        let facets = await rt.detectFacets()
        let _ = try await makePost(text: text, reply: replyref, facets: facets, embed: embed.isValid() ? embed : nil)
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
        .disabled(text.count > 300 || disablebuttons || (text.isEmpty && images.isEmpty))
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
        VStack(alignment: .leading) {
          TextViewWrapper(text: $text, placeholder: placeholder) {
            if images.count >= 4 {
              return
            }
            let imgData = NSPasteboard.general.data(forType: .png)
            if let imgData {
              DispatchQueue.main.async {
                if let image = NSImage(data: imgData) {
                  images.append(.init(image: Image(nsImage: image), data: imgData))
                }
              }
            }
          }
          .frame(height: 200)
          ScrollView(.horizontal) {
            HStack {
              ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                image.image
                  .resizable()
                  .scaledToFill()
                  .frame(width: 150, height: 150)
                  .clipped()
                  .overlay(alignment: .topTrailing) {
                    Button {
                      images.remove(at: index)
                    } label : {
                      Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(
                            .secondary,
                            .clear,
                            .black
                        )
                        .padding(5)
                    }
                    .buttonStyle(.borderless)
                    .font(.title)
                  }
              }
            }
          }
        }
      }
      .padding([.leading], 20)
      
      Divider()
        .padding(.vertical, 5)
      HStack {
        Button("\(Image(systemName: "photo"))") {
          let panel = NSOpenPanel();
          panel.allowsMultipleSelection = true;
          panel.canChooseDirectories = false;
          panel.allowedContentTypes = [.image]
          if (panel.runModal() == .OK) {
            for url in panel.urls {
              if images.count >= 4 {
                break
              }
              if let data = try? Data(contentsOf: url) {
                if let image = NSImage(data: data) {
                  images.append(.init(image: Image(nsImage: image), data: data))
                }
              }
            }
          }
        }
        .buttonStyle(.plain)
        .foregroundColor(.accentColor)
        .disabled(images.count >= 4)
        .font(.title)
        .padding(.leading)
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
