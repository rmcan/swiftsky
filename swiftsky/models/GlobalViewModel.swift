//
//  GlobalViewModel.swift
//  swiftsky
//

import Foundation

class GlobalViewModel: ObservableObject {
  static let shared = GlobalViewModel()
  @Published var profile: ActorDefsProfileViewDetailed = ActorDefsProfileViewDetailed()
}
