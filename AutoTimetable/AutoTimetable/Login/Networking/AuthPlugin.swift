//
//  TokenManager.swift
//  AutoTimetable
//
//  Created by 황인성 on 7/8/25.
//

import Foundation
import Moya

final class AuthPlugin: PluginType {
    
    let accessTokenKey = "accessToken"
    let refreshTokenKey = "refreshToken"
    
    private let provider = MoyaProvider<AuthAPI>()
    weak var viewModel: AuthViewModel?
    
    init(viewModel: AuthViewModel?) {
        self.viewModel = viewModel
    }
    
    // 요청이 시작될 때 호출
    func willSend(_ request: RequestType, target: TargetType) {
        print("요청을 보냅니다: \(request.request?.url?.absoluteString ?? "")")
    }
    
    // 응답을 받은 후 호출
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            print("응답을 받았습니다: \(response.statusCode)")
            
            if response.statusCode == 401 {
                // 이미 재시도한 요청인지 확인
                if let retried = (target as? RetriableTargetType)?.hasRetried, retried {
                    print("🔁 이미 재시도한 요청입니다. 무한 루프 방지를 위해 로그아웃 처리")
                    forceLogout()
                    return
                }
                
                // 토큰 재발급 시도
                reissueToken { [weak self] success in
                    guard let self = self else { return }
                    if success {
                        self.retryOriginalRequest(target: target, hasRetried: true)
                    } else {
                        self.forceLogout()
                    }
                }
            }
            
        case .failure(let error):
            print("❌ 오류 발생: \(error.localizedDescription)")
            viewModel?.networkErrorAlert = true
        }
    }
    
    // MARK: - 토큰 재발급
    private func reissueToken(completion: @escaping (Bool) -> Void) {
        provider.request(.reissueToken) { result in
            switch result {
            case .success(let response):
                if let apiResponse = try? response.map(ApiResponse<Token>.self),
                   let token = apiResponse.content {
                    print("🚨 재발급 토큰 매핑 성공")
                    print("access: \(token.access)")
                    print("refresh: \(token.refresh)")
                    
                    self.saveToken(token.access)
                    self.saveRefreshToken(token.refresh)
                    completion(true)
                } else {
                    print("🚨 토큰 매핑 실패")
                    completion(false)
                }
            case .failure:
                print("🚨 토큰 재발급 요청 실패")
                completion(false)
            }
        }
    }
    
    // MARK: - 원래 요청 재시도
    private func retryOriginalRequest(target: TargetType, hasRetried: Bool, completion: ((Result<Response, MoyaError>) -> Void)? = nil) {
        let retryTarget = RetriableTarget(original: target, hasRetried: hasRetried)
        let retryProvider = MoyaProvider<MultiTarget>(plugins: [self])
        
        retryProvider.request(MultiTarget(retryTarget)) { result in
            switch result {
            case .success(let response):
                print("🔁 재시도 성공: \(response.statusCode)")
                completion?(.success(response))
            case .failure(let error):
                print("❌ 재시도 실패: \(error.localizedDescription)")
                self.forceLogout()
                completion?(.failure(error))
            }
        }
    }
    
    // MARK: - 로그아웃 처리
    private func forceLogout() {
        print("👋 로그아웃 처리됨")
        viewModel?.isLoggedIn = false
        deleteToken()
        deleteRefreshToken()
    }
    
    // MARK: - 토큰 관리
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


import Moya

/// 재시도 여부를 표시할 수 있는 프로토콜
protocol RetriableTargetType: TargetType {
    var hasRetried: Bool { get }
}

import Moya

/// 기존 TargetType을 감싸고, 재시도 여부를 포함하는 구조체
struct RetriableTarget: RetriableTargetType {
    let original: TargetType
    let hasRetried: Bool

    var baseURL: URL { original.baseURL }
    var path: String { original.path }
    var method: Moya.Method { original.method }
    var sampleData: Data { original.sampleData }
    var task: Task { original.task }
    var headers: [String : String]? { original.headers }
}
