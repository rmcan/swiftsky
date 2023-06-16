//
//  ErrorView.swift
//  swiftsky
//

import SwiftUI

struct ErrorView: View {
  let error: String
  var action: () -> ()
  var body: some View {
      Group {
        Text(error)
          .multilineTextAlignment(.center)
          .lineLimit(nil)
        Button("\(Image(systemName: "arrow.clockwise")) Retry") {
          action()
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
      }
      .frame(maxWidth: .infinity, alignment: .center)
    }
}

