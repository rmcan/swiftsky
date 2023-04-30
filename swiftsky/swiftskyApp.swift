//
//  swiftskyApp.swift
//  swiftsky
//

import SwiftUI

@main
struct swiftskyApp: App {
  @StateObject private var auth = Auth.shared
  @StateObject private var globalviewmodel = GlobalViewModel.shared
  init() {
    Client.shared.postInit()
    GlobalViewModel.shared.systemLanguageCode = Locale.preferredLanguageCodes[0]
    GlobalViewModel.shared.systemLanguage = Locale.current.localizedString(forLanguageCode: GlobalViewModel.shared.systemLanguageCode) ?? "en"
  }
  var body: some Scene {
    WindowGroup {
      SidebarView().sheet(isPresented: $auth.needAuthorization) {
        LoginView()
      }
    }
    .defaultSize(width: 1100, height: 650)
    .commands {
      CommandMenu("Account") {
        if let profile = globalviewmodel.profile {
          Text("@\(profile.handle)")
          Button("Sign out") {
            auth.signout()
          }
        }
      }
    }
    Settings {
      SettingsView()
    }
  }
}
