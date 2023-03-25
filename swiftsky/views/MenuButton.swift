//
//  MenuButton.swift
//  swiftsky
//

import Foundation
import SwiftUI

class MenuItem: NSMenuItem {
  init(title: String, action: @escaping () -> Void) {
    super.init(title: title, action: nil, keyEquivalent: "")
    super.setAction { _ in
      action()
    }
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

struct MenuButton: NSViewRepresentable {
  var items: () -> [MenuItem]
  init(_ items: @escaping () -> [MenuItem]) {
    self.items = items
  }
  func makeNSView(context: NSViewRepresentableContext<Self>) -> NSButton {
    let button = NSButton()
    button.title = ""
    button.image = NSImage(systemSymbolName: "ellipsis", accessibilityDescription: nil)
    button.bezelStyle = .texturedRounded
    button.isBordered = false
    let menu = NSMenu()
    let items = self.items()
    for item in items {
      menu.addItem(item)
    }
    button.setAction { _ in
      menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.frame.height + 5), in: button)
    }
    return button
  }
  func updateNSView(_ nsView: NSButton, context: NSViewRepresentableContext<Self>) {

  }
}
