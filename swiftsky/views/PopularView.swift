//
//  PopularView.swift
//  swiftsky
//

import SwiftUI

struct PopularView: View {
    @AppStorage("disablelanguageFilter") private var disablelanguageFilter = false
    @State var timeline: UnspeccedGetPopularOutput = UnspeccedGetPopularOutput()
    @Binding var path: NavigationPath
    var body: some View {
        List {
            Group {
                let Filteredfeed = timeline.feed.filter {
                    if disablelanguageFilter {
                        return true
                    }
                    let text = $0.post.record.text
                    let langcode = text.isEmpty ? "en" : $0.post.record.text.languageCode
                    return langcode == "en" || Locale.preferredLanguageCodes.contains(langcode)
                }
                ForEach(Filteredfeed) { post in
                    PostView(post: post.post, reply: post.reply, repost: post.reason, path: $path)
                        .padding([.top, .horizontal])
                        .contentShape(Rectangle())
                        .onTapGesture {
                            path.append(post)
                        }
                        .onAppear {
                            if post == Filteredfeed.last {
                                if let cursor = self.timeline.cursor {
                                    getPopular(before: cursor) { result in
                                        if let result = result {
                                            self.timeline.feed.append(contentsOf: result.feed)
                                            self.timeline.cursor = result.cursor
                                        }
                                    }
                                }
                            }
                        }
                    PostFooterView(post: post.post)
                        .padding(.leading, 68)
                    Divider()
                }
                if self.timeline.cursor != nil {
                    ProgressView().frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .listRowInsets(EdgeInsets())
          
        }
        .environment(\.defaultMinListRowHeight, 0.1)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .onAppear {
            getPopular() { result in
                if let result = result {
                    self.timeline = result
                }
            }
        }
        
    }
}
