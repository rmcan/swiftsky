//
//  swiftskyApp.swift
//  swiftsky
//

import SwiftUI

var dateformatter = RelativeDateTimeFormatter()

@main
struct swiftskyApp: App {
    @StateObject private var auth = Auth.shared
    init() {
        dateformatter.dateTimeStyle = .named
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
