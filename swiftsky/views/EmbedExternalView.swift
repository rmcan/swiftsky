//
//  EmbedExternalView.swift
//  swiftsky
//

import SwiftUI

struct EmbedExternalView: View {
  @State var record: EmbedExternalViewExternal
  @Environment(\.openURL) private var openURL
  var body: some View {
    Button {
      if let url = URL(string: record.uri) {
        openURL(url)
      }
    } label: {
      ZStack(alignment: .topLeading) {

        RoundedRectangle(cornerRadius: 10)
          .frame(maxWidth: .infinity)
          .opacity(0.02)

        VStack(alignment: .leading) {
          if let thumb = record.thumb {
            AsyncImage(url: URL(string: thumb)) {
              $0
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 400, height: 200)
                .clipped()
            } placeholder: {
              ProgressView()
                .frame(width: 400, height: 200)
            }
          }
          if !record.title.isEmpty {
            Text(record.title)
          }
          Text(record.uri)
            .foregroundColor(.secondary)
          if !record.description.isEmpty {
            Text(record.description)
              .lineLimit(2)
          }
        }
        .padding(10)
      }
      .fixedSize(horizontal: false, vertical: true)
      .padding(.bottom, 5)
      .frame(maxWidth: 400)
    }
    .buttonStyle(.plain)
    .contentShape(Rectangle())
  
  }
}
