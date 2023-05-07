//
//  EmbedPostView.swift
//  swiftsky
//

import SwiftUI

struct EmbedPostView: View {
  @State var embedrecord: EmbedRecordViewRecord
  @State var usernamehover: Bool = false
  @Binding var path: [Navigation]
  var markdown: String {
    var markdown = String()
    let rt = RichText(text: embedrecord.value.text, facets: embedrecord.value.facets)
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
    ZStack(alignment: .topLeading) {

      RoundedRectangle(cornerRadius: 10)
        .frame(maxWidth: .infinity)
        .opacity(0.02)

      VStack(alignment: .leading, spacing: 0) {
        HStack(alignment: .top) {
          AvatarView(url: embedrecord.author.avatar, size: 16)
          let displayname = embedrecord.author.displayName ?? embedrecord.author.handle

          Button {
            path.append(.profile(embedrecord.author.did))
          } label: {
            Text("\(displayname) \(Text(embedrecord.author.handle).foregroundColor(.secondary))")
              .fontWeight(.semibold)
              .underline(usernamehover)
          }
          .buttonStyle(.plain)
          .hoverHand {usernamehover = $0}
          .tooltip {
            ProfilePreview(did: embedrecord.author.did, path: $path)
          }
          Text(
            Formatter.relativeDateNamed.localizedString(
              fromTimeInterval: embedrecord.indexedAt.timeIntervalSinceNow)
          )
          .foregroundColor(.secondary)
        }

        Text(.init(markdown))
          .frame(maxHeight: 100)
        if let embed = embedrecord.embeds {
          ForEach(embed) { embed in
            if let external = embed.external {
              EmbedExternalView(record: external)
            }
            if let images = embed.images {
              HStack {
                ForEach(images, id: \.self) { image in
                  Button {
                    //previewurl = URL(string: image.fullsize)

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
                    .frame(width: imagewidth, height: imageheight)
                    .padding(.init(top: 5, leading: 0, bottom: 0, trailing: 0))
                    .cornerRadius(15)
                  }
                  .buttonStyle(.plain)
                }
              }
            }
          }
        }
      }
      .padding(10)

    }
    .fixedSize(horizontal: false, vertical: true)
    .padding(.bottom, 5)
  }
}
