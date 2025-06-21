//
//  AuthViewModel.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/5/25.
//

import Foundation
import Moya


class AuthViewModel: ObservableObject {
    
    private var provider: MoyaProvider<AuthAPI>!
    
    
    @Published var isLoggedIn: Bool = false
    
    let accessTokenKey = "accessToken"
    let refreshTokenKey = "refreshToken"
    
    
    init() {
        print("authViewModel init")
        deleteToken()
        deleteRefreshToken()
        // 플러그인 주입
//        let authPlugin = AuthPlugin(viewModel: self)
        self.provider = MoyaProvider<AuthAPI>()
        // 로그인 여부 확인
        self.isLoggedIn = (self.getToken() != nil)
    }
    
    
    // 로그인
    // 엑세스토근, 리프레쉬토큰 키체인으로 저장
    // 로그인 여부 변경
    func login(school: String, studentId: String, password: String) {
        provider.request(.login(school: school, studentId: studentId, password: password)) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
//                    let rawString = String(data: response.data, encoding: .utf8)
//                    print("서버 응답: \(rawString ?? "nil")")
                    print(response)
                    if let apiResponse = try? response.map(ApiResponse<Token>.self), let token = apiResponse.content {
                        
                        print("logIn매핑 성공🚨")
                        print("Access Token: \(token.access)")
                        print("Refresh Token: \(token.refresh)")
                        
                        self.saveToken(token.access)
                        self.saveRefreshToken(token.refresh)
                        self.isLoggedIn = true
                    }
                    else {
                        print("logIn매핑 실패🚨")
//                        self.LogInFailAlert = true
                    }
                case .failure:
                    print("logIn네트워크 요청 실패🚨")
                }
            }
        }
    }
    
    func mailSend(email: String, completion: @escaping () -> Void) {
        provider.request(.mailSend(email: email)) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print(response)
                    if let apiResponse = try? response.map(ApiResponse<EmptyContent>.self) {
                        print("✅ mailSend 매핑 성공: code=\(apiResponse.statusCode), message=\(apiResponse.message)")
                        completion()
                    }
                    else {
                        print("❌ mailSend 매핑 실패")
                    }
                case .failure:
                    print("mailSend 요청 실패🚨")
                }
            }
        }
    }
    
    func mailVerify(email: String, authCode: String, completion: @escaping () -> Void) {
        provider.request(.mailVerify(email: email, authCode: authCode)) { result in
            DispatchQueue.main.async {
                if case .success(let response) = result,
                   let apiResponse = try? response.map(ApiResponse<EmptyContent>.self),
                   apiResponse.statusCode.uppercased() == "OK" {
                    print("✅ 인증 성공: \(apiResponse.message)")
                    completion()
                } else {
                    print("❌ 인증 실패 또는 매핑 실패")
                }
            }
        }
    }
    
    func join(studentId: String, password: String, username: String, school: String, department: String, completion: @escaping () -> Void) {
        provider.request(.join(studentId: studentId, password: password, username: username, school: school, department: department)) { result in
            DispatchQueue.main.async {
                if case .success(let response) = result,
                   let apiResponse = try? response.map(ApiResponse<EmptyContent>.self),
                   apiResponse.statusCode.uppercased() == "OK" {
                    print("✅ join 성공: \(apiResponse.message)")
                    completion()
                } else {
                    print("❌ join 실패 또는 매핑 실패")
                }
            }
        }
    }
    
    func passwordReset(school: String, studentId: String, newPassword: String, completion: @escaping () -> Void) {
        provider.request(.passwordReset(school: school, studentId: studentId, newPassword: newPassword)) { result in
            DispatchQueue.main.async {
                if case .success(let response) = result,
                   let apiResponse = try? response.map(ApiResponse<EmptyContent>.self),
                   apiResponse.statusCode.uppercased() == "OK" {
                    print("✅ passwordReset 성공: \(apiResponse.message)")
                    completion()
                } else {
                    print("❌ passwordReset 실패 또는 매핑 실패")
                }
            }
        }
    }
    
    func checkDuplicatedMember(school: String, studentId: String, completion: @escaping (Bool) -> Void) {
        provider.request(.checkDuplicatedMember(studentId: studentId, school: school)) { result in
            DispatchQueue.main.async {
                if case .success(let response) = result,
                   let apiResponse = try? response.map(ApiResponse<EmptyContent>.self) {

                    switch apiResponse.statusCode.uppercased() {
                    case "OK":
                        print("✅ 가입 가능: \(apiResponse.message)")
                        completion(false)

                    case "CONFLICT":
                        print("⚠️ 이미 가입된 학번입니다: \(apiResponse.message)")
                        completion(true)

                    default:
                        print("❌ 처리 실패: \(apiResponse.statusCode) - \(apiResponse.message)")
                    }

                } else {
                    print("🚨 네트워크 또는 매핑 실패")
                }
            }
        }
    }
    
    
    
    
    // 토큰관리 메소드
    private func saveToken(_ token: String) {
        KeychainHelper.shared.save(token, forKey: accessTokenKey)
    }

    private func getToken() -> String? {
        return KeychainHelper.shared.read(forKey: accessTokenKey)
    }

    private func deleteToken() {
        KeychainHelper.shared.delete(forKey: accessTokenKey)
    }

    private func saveRefreshToken(_ token: String) {
        KeychainHelper.shared.save(token, forKey: refreshTokenKey)
    }

    private func getRefreshToken() -> String? {
        return KeychainHelper.shared.read(forKey: refreshTokenKey)
    }

    private func deleteRefreshToken() {
        KeychainHelper.shared.delete(forKey: refreshTokenKey)
    }
}
