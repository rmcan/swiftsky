//
//  swiftskyApp.swift
//  swiftsky
//

import SwiftUI

@main
struct swiftskyApp: App {
    @StateObject private var auth = Auth.shared
    init() {
        api.shared.postInit()
    }
    var body: some Scene {
        WindowGroup {
            SidebarView().sheet(isPresented: $auth.needAuthorization) {
                LoginView().frame(width: 300, height: 200)
            }
        }
    }
}
