//
//  ThreadViewModel.swift
//  swiftsky
//

import Foundation

class TranslateViewModel: ObservableObject {
  var text: String = ""
  func translatetext() {
    if translatedtext.isEmpty {
      Task {
        do {
          DispatchQueue.main.async {
            self.translatestatus = 1
          }
          let translatedtext = try await GoogleTranslate.translate(text: self.text, to: GlobalViewModel.shared.systemLanguageCode)
          DispatchQueue.main.async {
            self.translatedtext = translatedtext
            self.translatestatus = 2
            self.showtranslated = true
          }
        } catch {
          DispatchQueue.main.async {
            self.translatestatus = 0
            self.error = error.localizedDescription
          }
        }
      }
    }
    else {
      self.showtranslated.toggle()
    }
  }
  @Published var translatedtext = ""
  @Published var showtranslated = false
  @Published var translatestatus = 0
  @Published var error = ""
}
