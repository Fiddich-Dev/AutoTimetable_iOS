//
//  AuthAPI.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/5/25.
//

import Foundation
import Moya

enum AuthAPI {
    case healthCheck
    case join(studentId: String, password: String, username: String)
    case checkDuplicatedMember(studentId: String)
    case withdraw
    case login(studentId: String, password: String)
    case logout
    case reissueToken
    case passwordReset(studentId: String, newPassword: String)
    case mailSend(email: String)
    case mailVerify(email: String, authCode: String)
}


extension AuthAPI: TargetType {
    
    var baseURL: URL {
        URL(string: "https://ssku.shop")!
//        URL(string: "http://localhost:8080")!
    }
    
    var path: String {
        switch self {
        case .healthCheck:
            return "/"
        case .join:
            return "/members"
        case .checkDuplicatedMember:
            return "/members/check-duplicate"
        case .withdraw:
            return "/members/me"
        case .login:
            return "/login"
        case .logout:
            return "/logout"
        case .reissueToken:
            return "/reissue"
        case .passwordReset:
            return "/password-reset"
        case .mailSend:
            return "/mail/send"
        case .mailVerify:
            return "/mail/verify"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .healthCheck:
            return .get
        case .join:
            return .post
        case .checkDuplicatedMember:
            return .get
        case .withdraw:
            return .delete
        case .login:
            return .post
        case .logout:
            return .post
        case .reissueToken:
            return .post
        case .passwordReset:
            return .patch
        case .mailSend:
            return .post
        case .mailVerify:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .healthCheck:
            return .requestPlain
        case .join(let studentId, let password, let username):
            return .requestParameters(parameters: ["studentId": studentId, "password": password, "username": username], encoding: JSONEncoding.default)
        case .checkDuplicatedMember(let studentId):
            return .requestParameters(parameters: ["studentId" : studentId], encoding: URLEncoding.default)
        case .withdraw:
            return .requestPlain
        case .login(let studentId, let password):
            return .requestParameters(parameters: ["studentId": studentId, "password": password], encoding: JSONEncoding.default)
        case .logout:
            return .requestPlain
        case .reissueToken:
            return .requestPlain
        case .passwordReset(let studentId, let newPassword):
            return .requestParameters(parameters: ["studentId": studentId, "newPassword" : newPassword], encoding: JSONEncoding.default)
        case .mailSend(let email):
            return .requestParameters(parameters: ["email": email], encoding: JSONEncoding.default)
        case .mailVerify(let email, let authCode):
            return .requestParameters(parameters: ["email": email, "authCode": authCode], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .healthCheck:
            return ["Content-type": "application/json"]
        case .join:
            return ["Content-type": "application/json"]
        case .checkDuplicatedMember:
            return ["Content-type": "application/json"]
        case .withdraw:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .login:
            return ["Content-type": "application/json"]
        case .logout:
            return ["refresh": getRefreshToken() ?? "asd", "Content-type": "application/json"]
        case .reissueToken:
            return ["refresh": getRefreshToken() ?? "asd", "Content-type": "application/json"]
        case .passwordReset:
            return ["Content-type": "application/json"]
        case .mailSend:
            return ["Content-type": "application/json"]
        case .mailVerify:
            return ["Content-type": "application/json"]
        }
    }
    
    private func getToken() -> String? {
        return KeychainHelper.shared.read(forKey: "accessToken")
    }
    private func getRefreshToken() -> String? {
        return KeychainHelper.shared.read(forKey: "refreshToken")
    }
}
