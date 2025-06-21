//
//  AuthAPI.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/5/25.
//

import Foundation
import Moya

enum AuthAPI {
    case authSchoolLogin(school: String, id: String, password: String)
    case login(school: String, studentId: String, password: String)
    case mailSend(email: String)
    case mailVerify(email: String, authCode: String)
    case join(studentId: String, password: String, username: String, school: String, department: String)
    case passwordReset(school: String, studentId: String, newPassword: String)
    case checkDuplicatedMember(studentId: String, school: String)
    
}


extension AuthAPI: TargetType {
    
    var baseURL: URL {
        URL(string: "http://localhost:8080")!
    }
    
    var path: String {
        switch self {
        case .authSchoolLogin:
            return "/auth/school"
        case .login:
            return "/login"
        case .mailSend:
            return "/mail/send"
        case .mailVerify:
            return "/mail/verify"
        case .join:
            return "/join"
        case .passwordReset:
            return "/password-reset"
        case .checkDuplicatedMember:
            return "/checkDuplicatedMember"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .authSchoolLogin:
            return .post
        case .login:
            return .post
        case .mailSend:
            return .post
        case .mailVerify:
            return .post
        case .join:
            return .post
        case .passwordReset:
            return .post
        case .checkDuplicatedMember:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .authSchoolLogin(let school, let studentId, let password):
            let parameters: [String: Any] = ["school": school, "studentId": studentId, "password": password]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .login(let school, let studentId, let password):
            let parameters: [String: Any] = ["school": school, "studentId": studentId, "password": password]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .mailSend(let email):
            return .requestParameters(parameters: ["email": email], encoding: JSONEncoding.default)
        case .mailVerify(let email, let authCode):
            return .requestParameters(parameters: ["email": email, "authCode": authCode], encoding: JSONEncoding.default)
        case .join(let studentId, let password, let username, let school, let department):
            return .requestParameters(parameters: ["studentId": studentId, "password": password, "username": username, "school": school, "department": department, "role": "STUDENT"], encoding: JSONEncoding.default)
        case .passwordReset(let school, let studentId, let newPassword):
            return .requestParameters(parameters: ["school" : school, "studentId" : studentId, "newPassword" : newPassword], encoding: JSONEncoding.default)
        case .checkDuplicatedMember(let studentId, let school):
            return .requestParameters(parameters: ["studentId" : studentId, "school" : school], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .authSchoolLogin:
            return ["Content-type": "application/json"]
        case .login:
            return ["Content-type": "application/json"]
        case .mailSend:
            return ["Content-type": "application/json"]
        case .mailVerify:
            return ["Content-type": "application/json"]
        case .join:
            return ["Content-type": "application/json"]
        case .passwordReset:
            return ["Content-type": "application/json"]
        case .checkDuplicatedMember:
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
