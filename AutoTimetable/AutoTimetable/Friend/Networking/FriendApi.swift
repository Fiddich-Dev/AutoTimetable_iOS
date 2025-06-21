//
//  FriendApi.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/10/25.
//

import Foundation
import Moya

enum FriendApi {
    case getMyFriends
    case findPendingResponse
    case acceptFriendRequest(requesterId: Int64)
    case rejectFriendRequest(requesterId: Int64)
    case deleteFriend(friendId: Int64)
    case searchFriend(school: String, studentId: String)
    case sendFriendRequest(receiverId: Int64)
    
}


extension FriendApi: TargetType {
    
    
    public var baseURL: URL {
        URL(string: "http://localhost:8080")!
    }
    
    public var path: String {
        switch self {
        case .getMyFriends:
            return "/friend/getMyFriends"
        case .findPendingResponse:
            return "/friend/findPendingResponse"
        case .acceptFriendRequest:
            return "/friend/acceptFriendRequest"
        case .rejectFriendRequest:
            return "/friend/rejectFriendRequest"
        case .deleteFriend:
            return "/friend/deleteFriend"
        case .searchFriend:
            return "/friend/searchMemberByStudentId"
        case .sendFriendRequest:
            return "/friend/sendFriendRequest"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getMyFriends:
            return .get
        case .findPendingResponse:
            return .get
        case .acceptFriendRequest:
            return .post
        case .rejectFriendRequest:
            return .delete
        case .deleteFriend:
            return .delete
        case .searchFriend:
            return .get
        case .sendFriendRequest:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getMyFriends:
            return .requestPlain
        case .findPendingResponse:
            return .requestPlain
        case .acceptFriendRequest(let requesterId):
            return .requestParameters(parameters: ["requesterId": requesterId], encoding: JSONEncoding.default)
        case .rejectFriendRequest(let requesterId):
            return .requestParameters(parameters: ["requesterId": requesterId], encoding: URLEncoding.default)
        case .deleteFriend(let friendId):
            return .requestParameters(parameters: ["friendId": friendId], encoding: URLEncoding.default)
        case .searchFriend(let school, let studentId):
            return .requestParameters(parameters: ["school": school, "studentId": studentId], encoding: URLEncoding.default)
        case .sendFriendRequest(let receiverId):
            return .requestParameters(parameters: ["receiverId": receiverId], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getMyFriends:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .findPendingResponse:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .acceptFriendRequest:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .rejectFriendRequest:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .deleteFriend:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .searchFriend:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .sendFriendRequest:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        }
    }
    
    private func getToken() -> String? {
        return KeychainHelper.shared.read(forKey: "accessToken")
    }
    private func getRefreshToken() -> String? {
        return KeychainHelper.shared.read(forKey: "refreshToken")
    }
}
