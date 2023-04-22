//
//  gtranslate.swift
//  swiftsky
//

import Foundation

struct GoogleTranslate {
  static func translate(text: String, from: String = "auto", to: String) async throws -> String  {
    var urlComponents = URLComponents(string: "https://translate.googleapis.com/translate_a/t")!
    urlComponents.queryItems = [
      URLQueryItem(name: "client", value: "dict-chrome-ex"),
      URLQueryItem(name: "sl", value: from),
      URLQueryItem(name: "tl", value: to),
      URLQueryItem(name: "q", value: text),
    ]
    guard let url = urlComponents.url else {
      throw URLError(.badURL)
    }
    let request = URLRequest(url: url)
    let response = try await URLSession.shared.data(for: request)
    guard let object = try? JSONSerialization.jsonObject(with: response.0, options: []) else {
      throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Decode error: 0"])
    }
    guard let array = object as? [[String]] else {
      throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Decode error: 1"])
    }
    return array[0][0]
  }
}
