//
//  SearchActorView.swift
//  swiftsky
//

import SwiftUI

struct SearchActorSubView: View {
  var actor: ActorDefsProfileViewBasic
  var body: some View {
    HStack(alignment: .top) {
      AvatarView(url: actor.avatar, size: 40)
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
  @State private var scrollViewContentSize: CGSize = .zero
  var callback: ((ActorDefsProfileViewBasic) -> ())?
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(actorstypeahead.actors) { user in
        SearchActorSubView(actor: user)
          .padding([.top, .leading], 4)
          .frame(maxWidth: .infinity, alignment: .leading)
          .contentShape(Rectangle())
          .hoverHand()
          .onTapGesture {
            callback?(user)
          }
      }
      .frame(width: 250)
      .frame(minHeight: 40)
    }
  }
}

