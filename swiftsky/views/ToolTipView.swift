//
//  ToolTipView.swift
//  swiftsky
//

import SwiftUI

struct TooltipModifier<TootipContent: View>: ViewModifier {
  var content: TootipContent
  @State private var timer = Timer.publish(every: 1, on: .main, in: .common)
  @State private var lasthover: Date? = nil
  @State private var hoverinterval: Double = 0
  @State private var contenthovered = false
  @State private var tooltipPresented = false
  init(@ViewBuilder content: @escaping () -> TootipContent) {
    self.content = content()
  }
  func body(content: Content) -> some View {
    content
      .onReceive(timer) { _ in
        if let date = lasthover {
          hoverinterval = -date.timeIntervalSinceNow
        }
        else if (!contenthovered) {
          if hoverinterval > 0 {
            hoverinterval = 0
            timer.connect().cancel()
            tooltipPresented = false
          }
        }
        if !tooltipPresented {
          if hoverinterval >= 2 || contenthovered {
            tooltipPresented = true
          }
        }
      }
      .onHover {
        if $0 {
          lasthover = Date()
          if hoverinterval <= 0 {
            timer = Timer.publish(every: 1, on: .main, in: .common)
            let _ = timer.connect()
          }
        }
        else {
          lasthover = nil
        }
      }
      .popover(isPresented: .constant(tooltipPresented), arrowEdge: .bottom) {
        self.content
          .onHover {
            contenthovered = $0
          }
      }
  }
}
extension View {
  public func tooltip<Content>(@ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
    modifier(TooltipModifier(content: content))
  }
}
