//
//  ThreadPostView.swift
//  swiftsky
//

import QuickLook
import SwiftUI

struct ThreadPostview: View {
  @State var post: FeedDefsPostView
  @State var reply: String?
  @State var usernamehover: Bool = false
  @State var displaynamehover: Bool = false
  @State var previewurl: URL? = nil
  @State var deletepostfailed = false
  @State var deletepost = false
  @State var translateavailable = false
  @Binding var path: [Navigation]
  @StateObject var translateviewmodel = TranslateViewModel()
  var load: () async -> ()
  func delete() {
    Task {
      do {
        let result = try await repoDeleteRecord(uri: post.uri, collection: "app.bsky.feed.post")
        if result {
          await load()
        }
      } catch {
        deletepostfailed = true
      }
    }
  }
  var markdown: String {
    var markdown = String()
    let rt = RichText(text: post.record.text, facets: post.record.facets)
    for segment in rt.segments() {
      if let link = segment.link() {
        markdown += "[\(segment.text)](\(link))"
      }
      else if let mention = segment.mention() {
        markdown += "[\(segment.text)](swiftsky://profile?did=\(mention))"
      }
      else {
        markdown += segment.text
      }
    }
    return markdown
  }
  var body: some View {

    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .top) {
        AvatarView(url: post.author.avatar, size: 40)
        HStack(alignment: .firstTextBaseline) {
          let displayname = post.author.displayName ?? post.author.handle
          VStack(alignment: .leading) {
            Button {
              path.append(.profile(post.author.did))
            } label: {
              Text(displayname)
                .fontWeight(.semibold)
                .underline(usernamehover)
            }
            .buttonStyle(.plain)
            .hoverHand {usernamehover = $0}
            Button {
              path.append(.profile(post.author.did))
            } label: {
              Text("@\(post.author.handle)")
                .foregroundColor(.secondary)
                .fontWeight(.semibold)
                .underline(displaynamehover)
            }
            .buttonStyle(.plain)
            .onHover { ishovered in
              if ishovered {
                displaynamehover = true
                NSCursor.pointingHand.push()
              } else {
                displaynamehover = false
                NSCursor.pointingHand.pop()
              }
            }
          }

          Spacer()

          Group {
            MenuButton {
              var items: [MenuItem] = []
              items.append(
                MenuItem(title: "Share") {
                  print("Share")
                })
              items.append(
                MenuItem(title: "Report") {
                  print("Report")
                })
              if post.author.did == Client.shared.did {
                items.append(
                  MenuItem(title: "Delete") {
                    deletepost = true
                  })
              }
              return items
            }
            .frame(width: 30, height: 30)
            .contentShape(Rectangle())
            .onHover { ishovered in
              if ishovered {
                NSCursor.pointingHand.push()
              } else {
                NSCursor.pointingHand.pop()
              }
            }
          }
        }
      }

      if !post.record.text.isEmpty {
        Text(.init(markdown))
          .foregroundColor(.primary)
          .textSelection(.enabled)
          .padding(.vertical, 4)
        if self.translateavailable {
          TranslateView(viewmodel: translateviewmodel)
        }
      }
      if let embed = post.embed {
        if let images = embed.images {
          HStack {
            ForEach(images, id: \.self) { image in
              Button {
                previewurl = URL(string: image.fullsize)

              } label: {
                let imagewidth = 600.0 / Double(images.count)
                let imageheight = 600.0 / Double(images.count)
                AsyncImage(url: URL(string: image.thumb)) { image in
                  image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: imagewidth, height: imageheight)
                    .contentShape(Rectangle())
                    .clipped()

                } placeholder: {
                  ProgressView()
                    .frame(width: imagewidth, height: imageheight)
                }
                .padding(.init(top: 5, leading: 0, bottom: 5, trailing: 0))
                .cornerRadius(15)
              }
              .buttonStyle(.plain)
            }
          }
        }
        if let record: EmbedRecordViewRecord = embed.record {
          Button {
            path.append(.thread(record.uri))
          } label: {
            EmbedPostView(embedrecord: record, path: $path)
          }
          .buttonStyle(.plain)
          .contentShape(Rectangle())
        }
        if let external = embed.external {
          EmbedExternalView(record: external)
        }
      }
      Text(
        "\(Text(post.indexedAt, style: .time)) · \(Text(post.indexedAt, style: .date))"
      )
      .foregroundColor(.secondary)
      .padding(.bottom, 6)
    }
    .onAppear {
      if translateviewmodel.text.isEmpty && !post.record.text.isEmpty {
        if post.record.text.languageCode != GlobalViewModel.shared.systemLanguageCode {
          translateavailable = true
        }
        translateviewmodel.text = post.record.text
      }
    }
    .quickLookPreview($previewurl)
    .alert("Failed to delete post, please try again.", isPresented: $deletepostfailed, actions: {})
    .alert("Are you sure?", isPresented: $deletepost) {
      Button("Cancel", role: .cancel) {}
      Button("Delete", role: .destructive) {
        self.delete()
      }
    }
  }
}
