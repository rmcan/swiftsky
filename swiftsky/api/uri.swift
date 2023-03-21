//
//  uri.swift
//  swiftsky
//


let ATP_URI_REGEX = /(at:\/\/)?((?:did:[a-z0-9:%-]+)|(?:[a-z][a-z0-9.:-]*))(\/[^?#\s]*)?(\?[^#\s]+)?(#[^\s]+)?$/

class AtUri {
    private var hash: String
    private var host: String
    private var pathname: String
    public var rkey: String
    init(uri: String) {
        let parse = AtUri.parse(str: uri)
        self.hash = parse.hash
        self.host = parse.host
        self.pathname = parse.pathname
        self.rkey = parse.rkey
    }
    init(hash: String, host: String, pathname: String) {
        self.hash = hash
        self.host = host
        self.pathname = pathname
        self.rkey = String(pathname.split(separator: "/")[safe: 1] ?? "")
    }
    static func parse(str: String) -> AtUri {
        if let match = try? ATP_URI_REGEX.wholeMatch(in: str) {
            return AtUri(hash: "\(match.5 ?? "")", host: "\(match.2)", pathname: "\(match.3 ?? "")")
        }
        return AtUri(hash: "", host: "", pathname: "")
    }
}
