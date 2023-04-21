//
//  TextViewWrapper.swift
//  swiftsky
//

import SwiftUI

struct TextViewWrapper: NSViewRepresentable {
  @Binding var text: String
  var placeholder: String? = nil
  func makeNSView(context: Context) -> NSScrollView {
    let textView = NSTextView()
    textView.autoresizingMask = [.width, .height]
    textView.isEditable = true
    textView.allowsUndo = true
    textView.isContinuousSpellCheckingEnabled = true
    textView.drawsBackground = false
    textView.delegate = context.coordinator
    textView.isRichText = false
    textView.font = NSFont.systemFont(ofSize: 20)
    if let placeholder {
      textView.setValue(NSAttributedString(string: placeholder, attributes:  [.foregroundColor: NSColor.secondaryLabelColor, .font: textView.font!]),
                        forKey: "placeholderAttributedString")
    }
    let scrollView = NSScrollView()
    scrollView.hasVerticalScroller = true
    scrollView.documentView = textView
    return scrollView
  }
  
  func updateNSView(_ nsView: NSScrollView, context: Context) {
    
  }
  func makeCoordinator() -> Coordinator {
    return Coordinator(text: $text)
  }
  
  class Coordinator: NSObject, NSTextViewDelegate {
    @Binding private var text: String
    var autocomplete: NSPopover
    var searchtask: Task<Void, Never>? = nil
    init(text: Binding<String>) {
      self._text = text
      self.autocomplete = NSPopover()
      self.autocomplete.behavior = .transient
    }
    func textDidChange(_ notification: Notification) {
      searchtask?.cancel()
      guard let textView = notification.object as? NSTextView else { return }
      
      self.text = textView.string
      if textView.string.isEmpty {
        self.autocomplete.close()
        return
      }
      textView.textStorage?.addAttribute(.foregroundColor, value: NSColor.labelColor, range: NSMakeRange(0, self.text.utf16.count))
      let mentionmatches = self.text.matches(of: /(^|\s|\()(@)([a-zA-Z0-9.-]+)(\b)/)
      let urlmatches = self.text.matches(of: /(^|\s|\()((https?:\/\/[\S]+)|((?<domain>[a-z][a-z0-9]*(\.[a-z0-9]+)+)[\S]*))/)
      textView.textStorage?.enumerateAttributes(in: NSRange(self.text.startIndex..., in: self.text)) { (attributes, range, stop) in
        if attributes[.link] != nil {
          textView.textStorage?.removeAttribute(.link, range: range)
        }
      }
      for match in urlmatches {
        let nsrange = NSRange(match.2.startIndex..<match.2.endIndex, in: self.text)
        textView.textStorage?.addAttribute(.link, value: match.2, range: nsrange)
      }
      var dismisspopover = true
      for match in mentionmatches {
        let nsrange = NSRange(match.3.startIndex..<match.3.endIndex, in: self.text)
        textView.textStorage?.addAttribute(.foregroundColor, value: NSColor.linkColor, range: NSRange(location: nsrange.location - 1, length: nsrange.length + 1))

        let selectedrange = textView.selectedRange()
        if selectedrange.location <= (nsrange.location + nsrange.length) && selectedrange.location >= nsrange.location {
          dismisspopover = false
          self.searchtask = Task {
            let searchactors = try? await ActorSearchActorsTypeahead(limit: 5, term: String(match.output.0))
            if let searchactors {
              let searchactorview = SearchActorView(actorstypeahead: .constant(searchactors)) { user in
                self.autocomplete.close()
                textView.textStorage?.replaceCharacters(in: nsrange, with: "\(user.handle)")
                self.text = textView.attributedString().string
              }
              self.autocomplete.contentViewController = NSHostingController(rootView: searchactorview)
              let screenRect         = textView.firstRect(forCharacterRange: nsrange, actualRange: nil), //from https://github.com/mchakravarty/CodeEditorView/blob/d403292e5100d51300bd27dbdd2c5b13359e772b/Sources/CodeEditorView/CodeActions.swift#L73
                  nonEmptyScreenRect = NSRect(origin: screenRect.origin, size: CGSize(width: 1, height: 1)),
                  windowRect         = textView.window!.convertFromScreen(nonEmptyScreenRect)
              self.autocomplete.show(relativeTo: textView.enclosingScrollView!.convert(windowRect, from: nil), of: textView.enclosingScrollView!, preferredEdge: .maxY)
            }
            else {
              self.autocomplete.close()
            }
          }
        }
      }
      if dismisspopover {
        self.autocomplete.close()
      }
    }
  }
}
