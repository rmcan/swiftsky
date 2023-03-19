//
//  swiftskyApp.swift
//  swiftsky
//

import SwiftUI


extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

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
