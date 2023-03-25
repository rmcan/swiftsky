//
//  EmbedPostView.swift
//  swiftsky
//

import SwiftUI

struct EmbedPostView: View {
  @State var embedrecord: EmbedRecordPresentedRecord
  @State var usernamehover: Bool = false
  @Binding var path: NavigationPath

  var body: some View {
    ZStack(alignment: .topLeading) {

      RoundedRectangle(cornerRadius: 10)
        .frame(maxWidth: .infinity)
        .opacity(0.02)

      VStack(alignment: .leading, spacing: 0) {
        HStack(alignment: .top) {
          if let avatar = embedrecord.author.avatar {
            AvatarView(url: URL(string: avatar)!, size: 16)
          }
          let displayname = embedrecord.author.displayName ?? embedrecord.author.handle

          Button {
            path.append(embedrecord.author)
          } label: {
            Text("\(displayname) \(Text(embedrecord.author.handle).foregroundColor(.secondary))")
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
              fromTimeInterval: embedrecord.record.createdAt.timeIntervalSinceNow)
          )
          .foregroundColor(.secondary)
        }

        Text(embedrecord.record.text)
          .frame(maxHeight: 100)
      }
      .padding(10)

    }
    .fixedSize(horizontal: false, vertical: true)
    .padding(.bottom, 5)
  }
}
