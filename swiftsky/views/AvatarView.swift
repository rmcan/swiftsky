//
//  AvatarView.swift
//  swiftsky
//

import SwiftUI

struct AvatarView: View {
  let url: String?
  let size: CGFloat
  let blur: Bool
  init(url: String?, size: CGFloat, blur: Bool = false) {
    self.url = url
    self.size = size
    self.blur = blur
  }
  var body: some View {
    if let url {
      AsyncImage(url: URL(string: url)) { image in
        image
          .resizable()
          .blur(radius: blur ? 15 : 0, opaque: true)
          .aspectRatio(contentMode: .fill)
          .frame(width: size, height: size)
          .clipped()
      } placeholder: {
        ProgressView()
          .frame(width: size, height: size)
      }
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
