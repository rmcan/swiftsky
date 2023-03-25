//
//  AvatarView.swift
//  swiftsky
//

import SwiftUI

struct AvatarView: View {
  let url: URL
  let size: CGFloat
  var body: some View {
    CachedAsyncImage(url: url) { image in
      image
        .resizable()
        .aspectRatio(contentMode: .fill)
    } placeholder: {
      ProgressView()
    }
    .frame(width: size, height: size)
    .cornerRadius(size / 2)
  }
}
