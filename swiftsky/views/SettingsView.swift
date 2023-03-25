//
//  SettingsView.swift
//  swiftsky
//

import SwiftUI

struct SettingsView: View {
  var body: some View {
    TabView {
      GeneralSettingsView().tabItem {
        Label("General", systemImage: "gearshape")
      }
    }
    .frame(width: 450)
  }
}
