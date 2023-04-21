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
  func detectFacets() async -> [RichtextFacet] {
    var facets: [RichtextFacet] = []
    let mentionmatches = self.text.matches(of: /(^|\s|\()(@)([a-zA-Z0-9.-]+)(\b)/)
    let urlmatches = self.text.matches(of: /(^|\s|\()((https?:\/\/[\S]+)|((?<domain>[a-z][a-z0-9]*(\.[a-z0-9]+)+)[\S]*))/)
    for match in urlmatches {
      var uri = match.2
      if !uri.starts(with: "http") {
        uri = "https://\(uri)"
      }
      let facet = RichtextFacet(features: [RichtextFacetFeatures(type: "app.bsky.richtext.facet#link", uri: String(uri))], index: RichtextFacetByteSlice(byteEnd: text.utf8.distance(from: text.startIndex, to: match.2.endIndex), byteStart: text.utf8.distance(from: text.startIndex, to: match.2.startIndex)))
      facets.append(facet)
    }
    for match in mentionmatches {
      guard let did = try? await IdentityResolveHandle(handle: String(match.2)) else {
        continue
      }
      let facet = RichtextFacet(features: [RichtextFacetFeatures(type: "app.bsky.richtext.facet#mention", did: did.did)], index: RichtextFacetByteSlice(byteEnd: text.utf8.distance(from: text.startIndex, to: match.3.endIndex), byteStart: text.utf8.distance(from: text.startIndex, to: match.3.startIndex) - 1))
      facets.append(facet)
    }
    return facets
  }
  func segments() -> [RichTextSegment] {
    var segments: [RichTextSegment] = []
    var facets = self.facets ?? []
    if facets.count == 0 {
      segments.append(RichTextSegment(text: self.text))
      return segments
    }
    facets.sort()
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
