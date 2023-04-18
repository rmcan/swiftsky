//
//  SearchField.swift
//  swiftsky
//

import SwiftUI

struct SearchField: NSViewRepresentable {
  var textChanged: (String) async -> ()
  init(_ textChanged: @escaping (String) async -> ()) {
    self.textChanged = textChanged
  }
  class Coordinator: NSObject, NSSearchFieldDelegate {
    var parent: SearchField
    var task: Task<Void, Never>? = nil
    init(_ parent: SearchField) {
      self.parent = parent
    }
    func controlTextDidChange(_ notification: Notification) {
      guard let searchField = notification.object as? NSSearchField else {
        return
      }
      self.task?.cancel()
      self.task = Task {
        await self.parent.textChanged(searchField.stringValue)
      }
    }
  }
  func makeNSView(context: Context) -> NSSearchField {
    let searchfield = NSSearchField(frame: .zero)
    searchfield.delegate = context.coordinator
    return searchfield
  }
  func updateNSView(_ searchField: NSSearchField, context: Context) {
    
  }
  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }
}
