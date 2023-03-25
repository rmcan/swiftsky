//
//  keychain.swift
//  swiftsky
//

import Foundation

func updatekeychain(_ data: Data, service: String, account: String) {
  let query =
    [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: account,
    ] as CFDictionary

  let updatedData = [kSecValueData: data] as CFDictionary
  SecItemUpdate(query, updatedData)
}

func savekeychain(_ data: Data, service: String, account: String) {
  let query =
    [
      kSecValueData: data,
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: account,
    ] as CFDictionary

  let saveStatus = SecItemAdd(query, nil)

  if saveStatus == errSecDuplicateItem {
    updatekeychain(data, service: service, account: account)
  }
}

func readkeychain(service: String, account: String) -> Data? {
  let query =
    [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: account,
      kSecReturnData: true,
    ] as CFDictionary

  var result: AnyObject?
  SecItemCopyMatching(query, &result)
  return result as? Data
}
