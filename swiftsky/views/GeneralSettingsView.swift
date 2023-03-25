//
//  GeneralSettingsView.swift
//  swiftsky
//

import SwiftUI

struct GeneralSettingsView: View {
  @AppStorage("disablelanguageFilter") private var disablelanguageFilter = false

  var body: some View {
    Form {
      Toggle("Disable language filter", isOn: $disablelanguageFilter)
    }
    .padding(20)
  }
}
