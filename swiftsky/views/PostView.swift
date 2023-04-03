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
  @Binding var path: NavigationPath
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
          Text(
            "\(Image(systemName: "arrow.triangle.2.circlepath")) Reposted by \(repost.by.handle)"
          )
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
          .buttonStyle(.plain)
          .onHover { ishovered in
            if ishovered {
              usernamehover = true
              NSCursor.pointingHand.push()
            } else {
              usernamehover = false
              NSCursor.pointingHand.pop()
            }
          }

          Text(
            Formatter.relativeDateNamed.localizedString(
              fromTimeInterval: post.record.createdAt.timeIntervalSinceNow)
          )
          .font(.body)
          .foregroundColor(.secondary)

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
              if post.author.did == NetworkManager.shared.did {
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
          .frame(height: 0)
        }
        if let reply = reply {
          Text("Reply to @\(reply)").foregroundColor(.secondary)
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
                  let imagewidth = 500.0 / Double(images.count)
                  let imageheight = 500.0 / Double(images.count)
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
          if let record: EmbedRecordViewRecord = embed.record {
            Button {
              path.append(record)
            } label: {
              EmbedPostView(embedrecord: record, path: $path)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
          }
        }
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
