//
//  richtext.swift
//  swiftsky
//

import Foundation


struct RichTextSegment: Identifiable {
  let id = UUID()
  let text: String
  var facet: RichtextFacet? = nil
  
  func link() -> String? {
    facet?.features.first(where: {$0.uri != nil})?.uri
  }
  func mention() -> String? {
    facet?.features.first(where: {$0.did != nil})?.did
  }
}
struct RichText {
  let text: String
  let facets: [RichtextFacet]?
  func segments() -> [RichTextSegment] {
    var segments: [RichTextSegment] = []
    let facets = self.facets ?? []
    if facets.count == 0 {
      segments.append(RichTextSegment(text: self.text))
      return segments
    }
    var textCursor = 0
    var facetCursor = 0
    repeat {
      let currFacet = facets[facetCursor]
      if (textCursor < currFacet.index.byteStart) {
        segments.append(RichTextSegment(text: self.text[textCursor..<currFacet.index.byteStart]))
      }
      else if textCursor > currFacet.index.byteStart {
        facetCursor += 1
        continue
      }
      if (currFacet.index.byteStart < currFacet.index.byteEnd) {
        let subtext = self.text[currFacet.index.byteStart..<currFacet.index.byteEnd]
        segments.append(RichTextSegment(text: subtext, facet: currFacet))
      }
      textCursor = currFacet.index.byteEnd
      facetCursor += 1
    } while facetCursor < facets.count
    if textCursor < self.text.utf8.count {
      segments.append(RichTextSegment(text: self.text[textCursor..<self.text.utf8.count]))
    }
    return segments
  }
}
