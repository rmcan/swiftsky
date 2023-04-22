//
//  GlobalViewModel.swift
//  swiftsky
//

import Foundation

class GlobalViewModel: ObservableObject {
  static let shared = GlobalViewModel()
  var systemLanguageCode = ""
  var systemLanguage = ""
  @Published var profile: ActorDefsProfileViewDetailed = ActorDefsProfileViewDetailed()
}
