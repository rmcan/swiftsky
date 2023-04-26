//
//  EmbedExternalView.swift
//  swiftsky
//

import SwiftUI
import WebKit

struct YouTubeView: NSViewRepresentable {
  let video_id: String
  func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  func makeNSView(context: Context) -> WKWebView {
    let nsview = WKWebView()
    let url = URL(string: "https://www.youtube.com/embed/\(video_id)")!
    nsview.load(URLRequest(url: url))
    nsview.uiDelegate = context.coordinator
    return nsview
  }
  
  func updateNSView(_ nsView: WKWebView, context: Context) {
  }
  class Coordinator : NSObject, WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
      if navigationAction.targetFrame == nil {
        NSWorkspace.shared.open(navigationAction.request.url!)
      }
      return nil
    }
  }
}

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
          if let youtube = try? /(?:https?:\/\/)?(?:www\.)?youtu(?:be)?\.(?:com|be)(?:\/watch\/?\?v=|\/embed\/|\/)(\w+)/.wholeMatch(in: record.uri) {
            YouTubeView(video_id: String(youtube.1))
              .frame(width: 400, height: 200)
          } else if let thumb = record.thumb {
            CachedAsyncImage(url: URL(string: thumb)) {
              $0
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 400, height: 200)
                .clipped()
            } placeholder: {
              ProgressView()
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
