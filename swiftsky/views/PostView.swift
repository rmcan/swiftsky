//
//  PostView.swift
//  swiftsky
//

import QuickLook
import SwiftUI

struct PostView: View {
  @State var post: FeedDefsPostView
  @State var reply: String?
  @State var usernamehover: Bool = false
  @State var repost: FeedDefsFeedViewPostReason? = nil
  @State var previewurl: URL? = nil
  @State var deletepostfailed = false
  @State var deletepost = false
  @State var underlinereply = false
  @State var translateavailable = false
  @StateObject var translateviewmodel = TranslateViewModel()
  @Binding var path: [Navigation]
  func delete() {
    Task {
      do {
        let result = try await repoDeleteRecord(uri: post.uri, collection: "app.bsky.feed.post")
        if result {
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
    HStack(alignment: .top, spacing: 12) {
      AvatarView(url: post.author.avatar, size: 40)
      VStack(alignment: .leading, spacing: 2) {
        if let repost = repost {
          Text(
            "\(Image(systemName: "arrow.triangle.2.circlepath")) Reposted by \(repost.by.handle)"
          )
          .foregroundColor(.secondary)
        }
        HStack(alignment: .firstTextBaseline) {
          let displayname = post.author.displayName ?? post.author.handle

          Button {
            path.append(.profile(post.author.did))
          } label: {
            Text("\(displayname) \(Text(post.author.handle).foregroundColor(.secondary))")
              .fontWeight(.semibold)
              .underline(usernamehover)
          }
          .buttonStyle(.plain)
          .hoverHand {usernamehover = $0}
          .tooltip {
            ProfilePreview(did: post.author.did, path: $path)
          }
          Text(
            Formatter.relativeDateNamed.localizedString(
              fromTimeInterval: post.indexedAt.timeIntervalSinceNow)
          )
          .font(.body)
          .foregroundColor(.secondary)
          .help(post.indexedAt.formatted(date: .complete, time: .standard))

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
            .hoverHand()
          }
          .frame(height: 0)
        }
        if let reply = reply {
          HStack(spacing: 0) {
            Text("Reply to ").foregroundColor(.secondary)
            Button {
              path.append(.profile(reply))
            } label: {
              Text("@\(reply)").foregroundColor(Color(.linkColor))
                .underline(underlinereply)
                .hoverHand {
                  underlinereply = $0
                }
                .tooltip {
                  ProfilePreview(did: reply, path: $path)
                }
            }
            .buttonStyle(.plain)
          }
        }
        if !post.record.text.isEmpty {
          Text(.init(markdown))
            .textSelection(.enabled)
            .padding(.bottom, post.embed?.images == nil ? self.translateavailable ? 0 : 6 : 0)
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
                  let imagewidth = 500.0 / Double(images.count)
                  let imageheight = 500.0 / Double(images.count)
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
      }
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
