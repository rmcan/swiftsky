//
//  AvatarView.swift
//  swiftsky
//

import SwiftUI

struct AvatarView: View {
  let url: String?
  let size: CGFloat
  var body: some View {
    if let url {
      AsyncImage(url: URL(string: url)) { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fill)
          .clipped()
      } placeholder: {
        ProgressView()
      }
      .frame(width: size, height: size)
      .cornerRadius(size / 2)
    }
    else {
      Image(systemName: "person.crop.circle.fill")
        .resizable()
        .foregroundStyle(.white, Color.accentColor)
        .frame(width: size, height: size)
        .cornerRadius(size / 2)
    }
  }
}
