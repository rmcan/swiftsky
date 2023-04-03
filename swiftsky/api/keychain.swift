//
//  keychain.swift
//  swiftsky
//

import Foundation

func updatekeychain(_ data: Data, service: String, account: String) {
  let query: [CFString: Any] =
    [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: account,
    ]

  let updatedData = [kSecValueData: data] as CFDictionary
  SecItemUpdate(query as CFDictionary, updatedData)
}

func savekeychain(_ data: Data, service: String, account: String) {
  let query: [CFString: Any] =
    [
      kSecValueData: data,
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: account,
    ]

  let saveStatus = SecItemAdd(query as CFDictionary, nil)

  if saveStatus == errSecDuplicateItem {
    updatekeychain(data, service: service, account: account)
  }
}

func readkeychain(service: String, account: String) -> Data? {
  let query: [CFString: Any] =
    [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: account,
      kSecReturnData: true,
    ]

  var result: AnyObject?
  SecItemCopyMatching(query as CFDictionary, &result)
  return result as? Data
}
