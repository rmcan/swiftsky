//
//  extensions.swift
//  swiftsky
//

import Foundation
import NaturalLanguage
import SwiftUI

extension View {
  func hoverHand(callback: ((Bool) -> ())? = nil) -> some View {
    self
      .onHover {
        if $0 {
          NSCursor.pointingHand.push()
        }
        else {
          NSCursor.pop()
        }
        callback?($0)
      }
  }
}

extension ISO8601DateFormatter {
  convenience init(_ formatOptions: Options) {
    self.init()
    self.formatOptions = formatOptions
  }
}
extension RelativeDateTimeFormatter {
  convenience init(_ dateTimeStyle: DateTimeStyle) {
    self.init()
    self.dateTimeStyle = dateTimeStyle
  }
}
extension Formatter {
  static let iso8601withFractionalSeconds = ISO8601DateFormatter([
    .withInternetDateTime, .withFractionalSeconds,
  ])
  static let iso8601withTimeZone = ISO8601DateFormatter([.withInternetDateTime, .withTimeZone])
  static let relativeDateNamed = RelativeDateTimeFormatter(.named)
}
extension Date {
  var iso8601withFractionalSeconds: String {
    return Formatter.iso8601withFractionalSeconds.string(from: self)
  }
}
extension Collection {
  subscript(safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}
extension Locale {
  static var preferredLanguageCodes: [String] {
    return Locale.preferredLanguages.compactMap({
      Locale(identifier: $0).language.languageCode?.identifier
    })
  }
}
extension String {
  var languageCode: String {
    let recognizer = NLLanguageRecognizer()
    recognizer.processString(self)
    guard let languageCode = recognizer.dominantLanguage?.rawValue else { return "en" }
    return languageCode
  }
}
class NSAction<T>: NSObject {
  let action: (T) -> Void

  init(_ action: @escaping (T) -> Void) {
    self.action = action
  }

  @objc func invoke(sender: AnyObject) {
    action(sender as! T)
  }
}

extension NSButton {
  func setAction(_ closure: @escaping (NSButton) -> Void) {
    let action = NSAction<NSButton>(closure)
    self.target = action
    self.action = #selector(NSAction<NSButton>.invoke)
    objc_setAssociatedObject(
      self, "\(self.hashValue)", action, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
  }
}
extension NSMenuItem {
  func setAction(_ closure: @escaping (NSMenuItem) -> Void) {
    let action = NSAction<NSMenuItem>(closure)
    self.target = action
    self.action = #selector(NSAction<NSMenuItem>.invoke)
    objc_setAssociatedObject(
      self, "\(self.hashValue)", action, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
  }
}

extension Encodable {
  var dictionary: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap {
      $0 as? [String: Any]
    }
  }
}

extension String {
  subscript (bounds: CountableRange<Int>) -> String {
    if bounds.upperBound > self.utf8.count {
      return ""
    }
    let start = self.utf8.index(startIndex, offsetBy: bounds.lowerBound)
    let end = self.utf8.index(startIndex, offsetBy: bounds.upperBound)
    return String(self.utf8[start..<end])!
  }
}
