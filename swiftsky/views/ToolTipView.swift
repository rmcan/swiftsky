//
//  ToolTipView.swift
//  swiftsky
//

import SwiftUI

struct TooltipModifier<TootipContent: View>: ViewModifier {
  var content: TootipContent
  @State private var contenthovered = false
  @State private var isPresented = false
  @State private var work: DispatchWorkItem?
  init(@ViewBuilder content: @escaping () -> TootipContent) {
    self.content = content()
  }
  private func onHover(_ hovered: Bool) {
    self.work?.cancel()
    self.work = DispatchWorkItem(block: {
      self.isPresented = self.contenthovered
    })
    contenthovered = hovered
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: work!)
  }
  func body(content: Content) -> some View {
    content
      .onHover {
        onHover($0)
      }
      .popover(isPresented: $isPresented, arrowEdge: .bottom) {
        self.content
          .onHover {
            onHover($0)
          }
      }
  }
}
extension View {
  public func tooltip<Content>(@ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
    modifier(TooltipModifier(content: content))
  }
}
