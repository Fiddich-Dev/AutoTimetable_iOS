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
    
    @Published var isLoading: Bool = false
    
    @Published var networkErrorAlert = false
    
    @Published var isLoggedIn: Bool = false
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    let accessTokenKey = "accessToken"
    let refreshTokenKey = "refreshToken"
    
    init() {
        print("authViewModel init")
        deleteToken()
        deleteRefreshToken()
        // 플러그인 주입
        let authPlugin = AuthPlugin(viewModel: self)
        self.provider = MoyaProvider<AuthAPI>(plugins: [authPlugin])
        // 로그인 여부 확인
        self.isLoggedIn = (self.getToken() != nil)
    }
    
    // 로그인
    // 엑세스토근, 리프레쉬토큰 키체인으로 저장
    // 로그인 여부 변경
    func login(studentId: String, password: String) {
        self.isLoading = true
        provider.request(.login(studentId: studentId, password: password)) { result in
            DispatchQueue.main.async {
                
                defer { self.isLoading = false }
                
                switch result {
                case .success(let response):
                    print(response)
                    if let apiResponse = try? response.map(ApiResponse<Token>.self), let token = apiResponse.content {
                        print("✅ logIn매핑 성공")
                        print("Access Token: \(token.access)")
                        print("Refresh Token: \(token.refresh)")
                        
                        self.saveToken(token.access)
                        self.saveRefreshToken(token.refresh)
                        self.isLoggedIn = true
                    }
                    else {
                        print("🚨 logIn매핑 실패")
                        self.showAlert = true
                        self.alertMessage = "아이디나 비밀번호가 틀렸습니다."
                    }
                case .failure:
                    print("🚨 logIn네트워크 요청 실패")
                }
            }
        }
    }
    
    func mailSend(email: String, completion: @escaping () -> Void) {
        self.isLoading = true
        provider.request(.mailSend(email: email)) { result in
            DispatchQueue.main.async {
                
                defer { self.isLoading = false }
                
                switch result {
                case .success(let response):
                    if let apiResponse = try? response.map(ApiResponse<EmptyContent>.self) {
                        print("✅ mailSend 매핑 성공")
                        completion()
                    }
                case .failure:
                    print("🚨 mailSend 요청 실패")
                }
            }
        }
    }
    
    func mailVerify(email: String, authCode: String, completion: @escaping (Bool) -> Void) {
        self.isLoading = true
        provider.request(.mailVerify(email: email, authCode: authCode)) { result in
            DispatchQueue.main.async {
                
                defer { self.isLoading = false }
                
                switch result {
                case .success(let response):
                    if let apiResponse = try? response.map(ApiResponse<EmptyContent>.self) {
                        switch apiResponse.statusCode.uppercased() {
                        case "OK":
                            print("✅ 인증 성공")
                            completion(true)
                        case "CONFLICT":
                            print("⚠️ 인증 실패: \(apiResponse.message)")
                            completion(false)
                        default:
                            print("🚨 mailVerify 서버 응답 오류)")
                        }
                    }
                case .failure:
                    print("🚨 mailVerify 요청 실패")
                }
            }
        }
    }
    
    func join(studentId: String, password: String, username: String, completion: @escaping () -> Void) {
        self.isLoading = true
        provider.request(.join(studentId: studentId, password: password, username: username)) { result in
            DispatchQueue.main.async {
                
                defer { self.isLoading = false }
                
                switch result {
                case .success(let response):
                    if let apiResponse = try? response.map(ApiResponse<EmptyContent>.self) {
                        print("✅ join 매핑 성공")
                        completion()
                    }
                case .failure:
                    print("🚨 join 요청 실패")
                }
            }
        }
    }
    
    func passwordReset(studentId: String, newPassword: String, completion: @escaping () -> Void) {
        self.isLoading = true
        provider.request(.passwordReset(studentId: studentId, newPassword: newPassword)) { result in
            DispatchQueue.main.async {
                
                defer { self.isLoading = false }
                
                switch result {
                case .success(let response):
                    if let apiResponse = try? response.map(ApiResponse<EmptyContent>.self) {
                        print("✅ passwordReset 매핑 성공")
                        completion()
                    }
                case .failure:
                    print("🚨 passwordReset 요청 실패")
                }
            }
        }
    }
    
    func checkDuplicatedMember(studentId: String, completion: @escaping (Bool) -> Void) {
//        self.isLoading = true
        provider.request(.checkDuplicatedMember(studentId: studentId)) { result in
            DispatchQueue.main.async {
                
//                defer { self.isLoading = false }
                
                switch result {
                case .success(let response):
                    if let apiResponse = try? response.map(ApiResponse<EmptyContent>.self) {
                        switch apiResponse.statusCode.uppercased() {
                        case "OK":
                            print("✅ 가입 가능")
                            completion(false)
                        case "CONFLICT":
                            print("⚠️ 이미 가입된 학번입니다: \(apiResponse.message)")
                            completion(true)
                        default:
                            print("🚨 checkDuplicatedMember 서버 응답 오류)")
                        }
                    }
                case .failure:
                    print("🚨 checkDuplicatedMember 요청 실패")
                }
            }
        }
    }
    
    func logout() {
        self.isLoading = true
        provider.request(.logout) { result in
            DispatchQueue.main.async {
                
                defer { self.isLoading = false }
                
                switch result {
                case .success(let response):
                    if let apiResponse = try? response.map(ApiResponse<EmptyContent>.self) {
                        print("✅ logout매핑 성공")
                        self.deleteToken()
                        self.deleteRefreshToken()
                        self.isLoggedIn = false
                    }
                        
                case .failure:
                    print("🚨 logout네트워크 요청 실패")
                    
                }
            }
        }
    }
    
    func withdraw() {
        self.isLoading = true
        provider.request(.withdraw) { result in
            DispatchQueue.main.async {
                
                defer { self.isLoading = false }
                
                switch result {
                case .success(let response):
                    if let apiResponse = try? response.map(ApiResponse<EmptyContent>.self) {
                        print("✅ withdraw매핑 성공")
                        self.deleteToken()
                        self.deleteRefreshToken()
                        self.isLoggedIn = false
                    }
                case .failure:
                    print("🚨 withdraw매핑 실패")
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
