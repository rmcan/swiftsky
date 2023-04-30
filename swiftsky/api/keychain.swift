//
//  keychain.swift
//  swiftsky
//

import Foundation

struct Keychain {
  public static func get(_ key: String) -> Data? {
    let query: [CFString: Any] =
    [
      kSecClass      : kSecClassGenericPassword,
      kSecAttrAccount: key,
      kSecReturnData : true,
    ]
    var data: AnyObject?
    SecItemCopyMatching(query as CFDictionary, &data)
    return data as? Data
  }
  public static func set(_ value: Data, _ key: String) {
    let query: [CFString : Any] = [
      kSecClass       : kSecClassGenericPassword,
      kSecAttrAccount : key,
      kSecValueData   : value
    ]
    delete(key)
    SecItemAdd(query as CFDictionary, nil)
  }
  public static func delete(_ key: String) {
    let query: [CFString : Any] = [
      kSecClass       : kSecClassGenericPassword,
      kSecAttrAccount : key,
    ]
    SecItemDelete(query as CFDictionary)
  }
}
