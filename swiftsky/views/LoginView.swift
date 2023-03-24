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
                Task {
                    do {
                        let result = try await XrpcSessionCreate(identifier: username, password: password)
                        NetworkManager.shared.user.username = username
                        NetworkManager.shared.user.password = password
                        NetworkManager.shared.user.refreshJwt = result.refreshJwt
                        NetworkManager.shared.user.accessJwt = result.accessJwt
                        NetworkManager.shared.handle = result.handle
                        NetworkManager.shared.did = result.did
                        NetworkManager.shared.user.save()
                        DispatchQueue.main.async {
                            auth.needAuthorization = false
                        }
                    } catch {
                        if let error = error as? XrpcErrorDescription {
                            self.error = error.message
                            return
                        }
                        self.error = error.localizedDescription
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

