//
//  sessioncreate.swift
//  swiftsky
//

public struct SessionCreateOutput: Decodable, Hashable {
    let accessJwt: String
    let did: String
    let handle: String
    let refreshJwt: String
}

public enum SessionResult<SessionCreateOutput> {
    case succsess(SessionCreateOutput)
    case message(XrpcErrorDescription)
    case unknown
}

public func XrpcSessionCreate(identifier: String, password: String, completion: @escaping (SessionResult<SessionCreateOutput>)->()) {
    api.shared.POST(endpoint: "com.atproto.session.create",params: ["identifier": identifier, "password" : password], objectType: SessionCreateOutput.self, refreshToken: false) { result in
        switch result {
        case .success(let result):
            completion(SessionResult.succsess(result))
        case .failure(let error):
            if case .APIError(let failure) = error {
                completion(SessionResult.message(failure))
            }
            else {
                completion(SessionResult.unknown)
            }
            print(error)
        }
    }
}

