//
//  TextViewWrapper.swift
//  swiftsky
//

import SwiftUI

class NSTextViewSubclass: NSTextView{
  var onPaste: (() -> Void)? = nil
  func setPasteAction(action: (() -> Void)?) {
    onPaste = action
  }
  override func readSelection(from pboard: NSPasteboard) -> Bool {
    if let types = pboard.types {
      for type in types {
        if type == .png || type == .tiff {
          onPaste?()
          return false
        }
      }
    }
    return super.readSelection(from: pboard)
  }
  override var readablePasteboardTypes: [NSPasteboard.PasteboardType]  {
    [.png, .tiff, .string]
  }
}
struct TextViewWrapper: NSViewRepresentable {
  @Binding var text: String
  var placeholder: String? = nil
  var onPaste: (() -> Void)?
  init(text: Binding<String>, placeholder: String? = nil, onPaste: (() -> Void)? = nil) {
    self._text = text
    self.placeholder = placeholder
    self.onPaste = onPaste
  }
  func makeNSView(context: Context) -> NSScrollView {
    let textView = NSTextViewSubclass()
    textView.setPasteAction(action: onPaste)
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
      let mentionmatches = try? NSRegularExpression(pattern: "(^|\\s|\\()(@)([a-zA-Z0-9.-]+)(\\b)", options: [])
        .matches(in: self.text, range: NSRange(location: 0, length: self.text.utf16.count))
      let urlmatches = try? NSRegularExpression(pattern: "(^|\\s|\\()((https?:\\/\\/[\\S]+)|((?<domain>[a-z][a-z0-9]*(\\.[a-z0-9]+)+)[\\S]*))", options: [])
        .matches(in: self.text, range: NSRange(location: 0, length: self.text.utf16.count))
      textView.textStorage?.enumerateAttributes(in: NSRange(self.text.startIndex..., in: self.text)) { (attributes, range, stop) in
        if attributes[.link] != nil {
          textView.textStorage?.removeAttribute(.link, range: range)
        }
      }
      if let urlmatches {
        for match in urlmatches {
          let nsrange = match.range(at: 2)
          if let range = Range(nsrange, in: self.text) {
            textView.textStorage?.addAttribute(.link, value: self.text[range], range: nsrange)
          }
        }
      }
      
      var dismisspopover = true
      if let mentionmatches {
        for match in mentionmatches {
          let nsrange = match.range(at: 3)
          textView.textStorage?.addAttribute(.foregroundColor, value: NSColor.linkColor, range: match.range(at: 0))
          let selectedrange = textView.selectedRange()
          if let range = Range(nsrange, in: self.text) {
            let handle = self.text[range]
            if selectedrange.location <= (nsrange.location + nsrange.length) && selectedrange.location >= nsrange.location {
              dismisspopover = false
              self.searchtask = Task {
                let searchactors = try? await ActorSearchActorsTypeahead(limit: 5, term: String(handle))
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
          
        }
      }
      if dismisspopover {
        self.autocomplete.close()
      }
    }
  }
}
