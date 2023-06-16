//
//  Navigation.swift
//  swiftsky
//

enum Navigation: Hashable {
  case profile(String)
  case thread(String)
  case followers(String)
  case following(String)
  case feed(CustomFeedModel)
  enum Sidebar: Hashable {
    case home
    case discoverfeeds
    case notifications
    case profile(String)
    case feed(CustomFeedModel)
  }
}
