//
//  AvatarView.swift
//  swiftsky
//

import SwiftUI

struct AvatarView: View {
  let url: String?
  let size: CGFloat
  let blur: Bool
  let isFeed: Bool
  init(url: String?, size: CGFloat, blur: Bool = false, isFeed: Bool = false) {
    self.url = url
    self.size = size
    self.blur = blur
    self.isFeed = isFeed
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
      .cornerRadius(isFeed ? size / 4 : size / 2)
    }
    else {
      if isFeed {
        ZStack {
          RoundedRectangle(cornerSize: CGSize(width: size / 4, height: size / 4))
            .frame(width: size, height: size)
            .foregroundStyle(Color(red: 0.0, green: 0.439, blue: 1.0))
          Image("default-feed")
            .resizable()
            .foregroundStyle(.white)
            .frame(width: size / 1.5, height: size / 1.5)
        }
      }
      else {
        Image(systemName: "person.crop.circle.fill")
          .resizable()
          .foregroundStyle(.white, Color.accentColor)
          .frame(width: size, height: size)
          .cornerRadius(isFeed ? size / 4 : size / 2)
      }
    
    }
  }
}
