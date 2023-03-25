//
//  api.swift
//  swiftsky
//

import Combine
import Foundation
import SwiftUI

class NetworkManager {
  static let shared = NetworkManager()
  private let baseURL = "https://bsky.social/xrpc/"
  private let decoder: JSONDecoder
  public var user = AuthData()
  @AppStorage("did") public var did: String = ""
  @AppStorage("handle") public var handle: String = ""
  enum NetworkError: Error {
    case serverError(Int)
    case decodingError(Error)
  }
  enum httpMethod {
    case get
    case post
  }
  init() {
    self.decoder = JSONDecoder()
    self.decoder.dateDecodingStrategy = .custom({ decoder in
      let container = try decoder.singleValueContainer()
      let dateString = try container.decode(String.self)
      if let date = Formatter.iso8601withFractionalSeconds.date(from: dateString) {
        return date
      }
      if let date = Formatter.iso8601withTimeZone.date(from: dateString) {
        return date
      }
      throw DecodingError.dataCorruptedError(
        in: container, debugDescription: "Cannot decode date string \(dateString)")
    })
  }
  public func postInit() {

    if let user = AuthData.load() {
      self.user = user
      let group = DispatchGroup()
      group.enter()
      Task {
        do {
          let session = try await xrpcSessionGet()
          if self.did == session.did, self.handle == session.handle {
            Auth.shared.needAuthorization = false
          }
        } catch {

        }
        group.leave()
      }
      group.wait()
    }
  }
  private func refreshSession() async -> Bool {
    do {
      let result: SessionRefreshOutput = try await self.fetch(
        endpoint: "com.atproto.session.refresh", httpMethod: .post,
        authorization: self.user.refreshJwt, params: Optional<Bool>.none, retry: false)
      self.user.accessJwt = result.accessJwt
      self.user.refreshJwt = result.refreshJwt
      self.handle = result.handle
      self.did = result.did
      self.user.save()
      return true
    } catch {
      if error is xrpcErrorDescription {
        print(error)
      }
    }
    return false
  }
  func fetch<T: Decodable, U: Encodable>(
    endpoint: String, httpMethod: httpMethod = .get, authorization: String? = nil, params: U? = nil,
    retry: Bool = true
  ) async throws -> T {
    guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
      throw URLError(.badURL)
    }
    if httpMethod == .get, let params = params?.dictionary {
      urlComponents.queryItems = params.map {
        URLQueryItem(name: $0, value: "\($1)")
      }
    }
    guard let url = urlComponents.url else {
      throw URLError(.badURL)
    }

    var request = URLRequest(url: url)
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    if let authorization {
      request.addValue("Bearer \(authorization)", forHTTPHeaderField: "Authorization")
    }
    switch httpMethod {
    case .get:
      request.httpMethod = "GET"
    case .post:
      request.httpMethod = "POST"
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      if params != nil {
        request.httpBody = try? JSONEncoder().encode(params)
        request.addValue("\(request.httpBody?.count ?? 0)", forHTTPHeaderField: "Content-Length")
      }
    }

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw NetworkError.serverError(0)
    }

    guard 200...299 ~= httpResponse.statusCode else {
      do {
        let xrpcerror = try self.decoder.decode(xrpcErrorDescription.self, from: data)
        if authorization != nil && retry == true {
          if xrpcerror.error == "ExpiredToken" {
            if await self.refreshSession() {
              return try await self.fetch(
                endpoint: endpoint, httpMethod: httpMethod, authorization: self.user.accessJwt,
                params: params, retry: false)
            }
          }
          if xrpcerror.error == "AuthenticationRequired" {
            DispatchQueue.main.async {
              Auth.shared.needAuthorization = true
            }
          }
        }

        throw xrpcerror
      } catch {
        if error is xrpcErrorDescription {
          throw error
        }
        throw NetworkError.serverError(httpResponse.statusCode)
      }
    }

    if T.self == Bool.self {
      return true as! T
    }

    do {
      return try self.decoder.decode(T.self, from: data)
    } catch {
      throw NetworkError.decodingError(error)
    }

  }
}

public struct xrpcErrorDescription: Error, Decodable {
  let error: String?
  let message: String?
}

struct AuthData: Codable {
  var username: String = ""
  var password: String = ""
  var accessJwt: String = ""
  var refreshJwt: String = ""
  static public func load() -> AuthData? {
    if let userdata = readkeychain(service: "swiftsky.userData", account: "userData"),
      let user = try? JSONDecoder().decode(AuthData.self, from: userdata)
    {
      return user
    }
    return nil
  }
  public func save() {
    if let userdata = try? JSONEncoder().encode(self) {
      savekeychain(userdata, service: "swiftsky.userData", account: "userData")
    }
  }
}

class Auth: ObservableObject {
  static let shared = Auth()
  @Published var needAuthorization: Bool = true
}
