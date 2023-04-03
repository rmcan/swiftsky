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
      Button {
        disablebutton = true
        Task {
          do {
            let result = try await ServerCreateSession(identifier: username, password: password)
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
            if let error = error as? xrpcErrorDescription {
              self.error = error.message
              return
            }
            self.error = error.localizedDescription
          }
          disablebutton = false
        }
      } label: {
        Text("Sign in").frame(minWidth: 0, maxWidth: 50)
      }
      .disabled(disablebutton)
      .keyboardShortcut(.defaultAction)
      if let error = self.error {
        Text(error)
          .foregroundColor(.red)
      }
      Button {
        exit(0)
      } label: {
        Text("Quit").frame(minWidth: 0, maxWidth: 50)
      }
    }
  }
}
