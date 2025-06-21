//
//  TimetableApi.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/13/25.
//

import Foundation
import Moya


enum TimetableApi {
    case getAllLectures
}

extension TimetableApi: TargetType {
    
    
    public var baseURL: URL {
        URL(string: "http://localhost:8080")!
    }
    
    public var path: String {
        switch self {
            
        case .getAllLectures:
            return "/getAllLectures"
        }
    }
    
    var method: Moya.Method {
        switch self {

        case .getAllLectures:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {

        case .getAllLectures:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {

        case .getAllLectures:
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
