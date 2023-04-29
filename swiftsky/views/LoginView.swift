//
//  LoginView.swift
//  swiftsky
//

import SwiftUI
struct LoginView: View {
  @State private var handle: String = ""
  @State private var password: String = ""
  @State private var error: String = ""
  @State private var isButtonDisabled: Bool = false
  @StateObject private var auth = Auth.shared
  private func signin() {
    Task {
      isButtonDisabled = true
      do {
        let result = try await ServerCreateSession(identifier: handle, password: password)
        NetworkManager.shared.user.refreshJwt = result.refreshJwt
        NetworkManager.shared.user.accessJwt = result.accessJwt
        NetworkManager.shared.handle = result.handle
        NetworkManager.shared.did = result.did
        NetworkManager.shared.user.save()
        DispatchQueue.main.async {
          auth.needAuthorization = false
        }
      } catch {
        self.error = error.localizedDescription
      }
      isButtonDisabled = false
    }
  }
  var body: some View {
    Form {
      Section {
        LabeledContent("Handle or email address") {
          TextField("Handle", text: $handle)
            .textContentType(.username)
            .multilineTextAlignment(.trailing)
            .labelsHidden()
        }
        LabeledContent("App password") {
          SecureField("Password", text: $password)
            .textContentType(.oneTimeCode)
            .multilineTextAlignment(.trailing)
            .labelsHidden()
        }
      } header: {
        error.isEmpty ? Text("Please sign in to continue.") : Text(error).foregroundColor(.red)
      }
    }
    .formStyle(.grouped)
    .navigationTitle("Sign in")
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button("Sign in") {
          signin()
        }
        .disabled(isButtonDisabled || (handle.isEmpty || password.isEmpty))
      }
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel", role: .cancel) {
          exit(0)
        }
      }
    }

  }
}
