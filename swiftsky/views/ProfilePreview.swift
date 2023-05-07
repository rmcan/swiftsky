//
//  ProfilePreview.swift
//  swiftsky
//

import SwiftUI

struct ProfilePreview: View {
  @State var profile: ActorDefsProfileViewBasic
  var body: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .top) {
        AvatarView(url: profile.avatar, size: 40)
        Spacer()
        Button("Follow") {
          
        }
        .padding(.trailing, 10)
      }
      Text(profile.displayName!)
      Text("@\(profile.handle)").foregroundColor(.secondary)
    }
    .padding([.top, .leading], 10)
     
  }
}
