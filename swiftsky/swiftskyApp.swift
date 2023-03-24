//
//  swiftskyApp.swift
//  swiftsky
//

import SwiftUI

@main
struct swiftskyApp: App {
    @StateObject private var auth = Auth.shared
    init() {
        NetworkManager.shared.postInit()
    }
    var body: some Scene {
        WindowGroup {
            SidebarView().sheet(isPresented: $auth.needAuthorization) {
                LoginView().frame(width: 300, height: 200)
            }
        }
        .defaultSize(width: 1100, height: 650)
        Settings {
            SettingsView()
        }
    }
}
