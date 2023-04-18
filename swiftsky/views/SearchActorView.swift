//
//  SearchActorView.swift
//  swiftsky
//

import SwiftUI

struct SearchActorSubView: View {
  var actor: ActorDefsProfileViewBasic
  var body: some View {
    HStack(alignment: .top) {
      if let avatar = actor.avatar {
        AvatarView(url: URL(string: avatar)!, size: 40)
      } else {
        Image(systemName: "person.crop.circle.fill")
          .resizable()
          .foregroundColor(.accentColor)
          .frame(width: 40, height: 40)
          .cornerRadius(20)
      }
      VStack(alignment: .leading) {
        let displayname = actor.displayName ?? actor.handle
        Text(displayname)
          .lineLimit(1)
        Text("@\(actor.handle)")
          .lineLimit(1)
          .foregroundColor(.secondary)
      }
    }
  }
}
struct SearchActorView: View {
  @Binding var actorstypeahead: ActorSearchActorsTypeaheadOutput
  @Binding var path: NavigationPath
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(actorstypeahead.actors) { user in
        SearchActorSubView(actor: user)
          .padding([.top, .leading], 4)
          .frame(maxWidth: .infinity, alignment: .leading)
          .contentShape(Rectangle())
          .hoverHand()
          .onTapGesture {
            path.append(user)
          }
      }
    }
    .frame(width: 250)
    .frame(minHeight: 40)
  }
}

