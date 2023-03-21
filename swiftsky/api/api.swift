//
//  api.swift
//  swiftsky
//

import Foundation
import Combine
import SwiftUI

public struct XrpcErrorDescription: Decodable {
    let error: String?
    let message: String?
}

struct AuthData: Codable {
    var username: String = ""
    var password: String = ""
    var accessJwt: String = ""
    var refreshJwt: String = ""
    static public func load() -> AuthData?
    {
        if let userdata = readkeychain(service: "swiftsky.userData", account: "userData"), let user = try? JSONDecoder().decode(AuthData.self, from: userdata) {
            return user
        }
        return nil
    }
    public func save()
    {
        if let userdata = try? JSONEncoder().encode(self) {
            savekeychain(userdata, service: "swiftsky.userData", account: "userData")
        }
    }
}

class Auth: ObservableObject {
    static let shared = Auth()
    @Published var needAuthorization: Bool = true
}

class api {
    static public let shared = api()
    private let baseURL = "https://bsky.social/xrpc/"
    private let decoder: JSONDecoder
    public var user = AuthData()
    public var needAuthorization: Binding<Bool> = .constant(true);
    @AppStorage("did") public var did: String = ""
    @AppStorage("handle") public var handle: String = ""

    enum RequestType {
        case GET
        case POST
    }
    enum NetworkError: Error {
        case networkerror(Error)
        case parseError(Error)
        case APIError(XrpcErrorDescription)
        case unknown
    }

    enum Result<T> {
        case success(T)
        case failure(NetworkError)
    }
    
    
    private func refreshSession(completion: @escaping ()->())
    {
        self.POST(endpoint: "com.atproto.session.refresh", objectType: SessionRefreshOutput.self, authorization: self.user.refreshJwt, refreshToken: false) { (result) -> ()  in
            switch result {
            case .success(let result):
                self.user.accessJwt = result.accessJwt
                self.user.refreshJwt = result.refreshJwt
                self.handle = result.handle
                self.did = result.did
                self.user.save()
            case .failure(let result):
                print(result)
            }
            completion()
        }
    }
    
    init() {
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = Formatter.iso8601withFractionalSeconds.date(from: dateString) {
                return date
            }
            if let date = Formatter.iso8601withTimeZone.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        })
    }
    public func postInit() {
        if let user = AuthData.load() {
            self.user = user
            let session = XrpcSessionGet()
            if let session = session {
                if self.did == session.did, self.handle == session.handle {
                    Auth.shared.needAuthorization = false
                }
            }
        }
    }
    
    public func doReuqest<T: Decodable>(endpoint: String, params: [String: Any]? = nil, requestType: RequestType, objectType: T.Type, authorization: String? = nil, refreshToken: Bool, completion: @escaping (Result<T>)->()) {
        var urlComponents = URLComponents(string: baseURL + endpoint)!
        if requestType == RequestType.GET {
            if let params = params {
                urlComponents.queryItems = []
                for (_, value) in params.enumerated() {
                    urlComponents.queryItems?.append(URLQueryItem(name: value.key, value: value.value as? String ?? ""))
                }
            }
        }

        if let url = urlComponents.url {
            var request = URLRequest(url: url)
            if requestType == RequestType.GET {
                request.httpMethod = "GET"
            } else if requestType == RequestType.POST {
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                if let params = params {
                    request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                }
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            if let authorization = authorization {
                request.addValue("Bearer \(authorization)", forHTTPHeaderField: "Authorization")
            }
            URLSession.shared.dataTask(with: request) { data, response, error in

                guard error == nil else {
                    completion(Result.failure(NetworkError.networkerror(error!)))
                    return
                }
                guard let responseData = data else {
                    completion(Result.failure(NetworkError.unknown))
                    return
                }
                if let httpresponse = response as? HTTPURLResponse {
                    if 200 ... 299 ~= httpresponse.statusCode {
                        if objectType == Bool.self {
                            completion(Result.success(true as! T))
                        }
                        else {
                            do {
                                let decodedObject = try self.decoder.decode(objectType.self, from: responseData)
                                completion(Result.success(decodedObject))
                            } catch let er {
                                completion(Result.failure(NetworkError.parseError(er as! DecodingError)))
                                print (er)
                            }
                        }
                    }
                    else {
                        do {
                            let decodedObject = try self.decoder.decode(XrpcErrorDescription.self, from: responseData)
                            if let xrpcerror = decodedObject.error {
                                if refreshToken {
                                    if xrpcerror == "ExpiredToken" {
                                        print("Token expired, refreshing")
                                        self.refreshSession() {
                                            self.doReuqest(endpoint: endpoint,params: params, requestType: requestType, objectType: objectType, authorization: self.user.accessJwt, refreshToken: false, completion: completion)
                                        }
                                        return
                                    }
                                }
                                if authorization != nil {
                                    if xrpcerror == "AuthenticationRequired" {
                                        DispatchQueue.main.async {
                                            Auth.shared.needAuthorization = true
                                        }
                                    }
                                }
                            }
                            completion(Result.failure(NetworkError.APIError(decodedObject)))
                        } catch let er {
                            completion(Result.failure(NetworkError.unknown))
                            print (er)
                        }
                    }
                }
                else {
                    completion(Result.failure(NetworkError.unknown))
                }
                
                
            }.resume()
        
        }
    }
    
    
    
    public func GET<T: Decodable>(endpoint: String, params: [String: String]? = nil, objectType: T.Type, authorization: String? = nil, refreshToken: Bool = true, completion: @escaping (Result<T>)->()) {
        doReuqest(endpoint: endpoint, params: params, requestType: RequestType.GET, objectType: objectType, authorization: authorization, refreshToken: refreshToken, completion: completion)
    }
    public func POST<T: Decodable>(endpoint: String, params: [String: Any]? = nil, objectType: T.Type, authorization: String? = nil, refreshToken: Bool = true, completion: @escaping (Result<T>)->()) {
        doReuqest(endpoint: endpoint, params: params, requestType: RequestType.POST, objectType: objectType, authorization: authorization, refreshToken: refreshToken, completion: completion)
    }
}
