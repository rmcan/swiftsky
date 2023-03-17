//
//  LoginView.swift
//  swiftsky
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var error: String? = nil
    @State private var disablebutton: Bool = false
    @StateObject private var auth = Auth.shared
    var body: some View {
        VStack {
            Text("Please sign in to continue.")
            TextField("Username or email address", text: $username)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            Button("Sign in") {
                disablebutton = true
                XrpcSessionCreate(identifier: username, password: password) { result in
                    switch result {
                    case.succsess(let result):
                        api.shared.user.username = username
                        api.shared.user.password = password
                        api.shared.user.refreshJwt = result.refreshJwt
                        api.shared.user.accessJwt = result.accessJwt
                        api.shared.handle = result.handle
                        api.shared.did = result.did
                        api.shared.user.save()
                        DispatchQueue.main.async {
                            auth.needAuthorization = false
                        }
                        
                    case .message(let message):
                        error = message.message
                    case .unknown:
                        error = "Failed to connect to server"
                    }
                    disablebutton = false
                }
            }
            .disabled(disablebutton)
            .keyboardShortcut(.defaultAction)
            if let error = self.error {
                Text(error)
                .foregroundColor(.red)
            }
        }
    }
}

