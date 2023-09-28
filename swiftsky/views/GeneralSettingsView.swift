//
//  GeneralSettingsView.swift
//  swiftsky
//

import SwiftUI

struct GeneralSettingsView: View {
  @AppStorage("disablelanguageFilter") private var disablelanguageFilter = false
  @AppStorage("hidelikecount") private var hidelikecount = false
  @AppStorage("hiderepostcount") private var hiderepostcount = false
  var body: some View {
    Form {
      Toggle("Disable language filter", isOn: $disablelanguageFilter)
      Toggle("Hide like count", isOn: $hidelikecount)
      Toggle("Hide repost count", isOn: $hiderepostcount)
    }
    .padding(20)
  }
}
