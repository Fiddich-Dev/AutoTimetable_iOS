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
    case sendFriendRequest(receiverId: Int64)
    case acceptFriendRequest(requesterId: Int64)
    case rejectFriendRequest(requesterId: Int64)
    case deleteFriend(friendId: Int64)
    case searchFriend(studentId: String, page: Int, size: Int)
    case compareLectureWithFriend(year: String, semester: String, memberIds: [Int64])
    case compareTimeWithFriend(year: String, semester: String, memberIds: [Int64])
}


extension FriendApi: TargetType {
    
    
    public var baseURL: URL {
        URL(string: "https://ssku.shop")!
//        URL(string: "http://localhost:8080")!
    }
    
    public var path: String {
        switch self {
        case .getMyFriends:
            return "/friends"
        case .findPendingResponse:
            return "/friends/pending/responses"
        case .sendFriendRequest:
            return "/friends/request"
        case .acceptFriendRequest:
            return "/friends/accept"
        case .rejectFriendRequest:
            return "/friends/request"
        case .deleteFriend(let friendId):
            return "/friends/\(friendId)"
        case .searchFriend:
            return "/friends/search"
        case .compareLectureWithFriend:
            return "/timetables/compare-lecture"
        case .compareTimeWithFriend:
            return "/timetables/compare-time"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getMyFriends:
            return .get
        case .findPendingResponse:
            return .get
        case .sendFriendRequest:
            return .post
        case .acceptFriendRequest:
            return .post
        case .rejectFriendRequest:
            return .delete
        case .deleteFriend:
            return .delete
        case .searchFriend:
            return .get
        case .compareLectureWithFriend:
            return .post
        case .compareTimeWithFriend:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getMyFriends:
            return .requestPlain
        case .findPendingResponse:
            return .requestPlain
        case .sendFriendRequest(let receiverId):
            return .requestParameters(parameters: ["memberId": receiverId], encoding: JSONEncoding.default)
        case .acceptFriendRequest(let requesterId):
            return .requestParameters(parameters: ["memberId": requesterId], encoding: JSONEncoding.default)
        case .rejectFriendRequest(let requesterId):
            return .requestParameters(parameters: ["requesterId": requesterId], encoding: URLEncoding.default)
        case .deleteFriend:
            return .requestPlain
        case .searchFriend(let studentId, let page, let size):
            return .requestParameters(parameters: ["keyword": studentId, "page": page, "size": size], encoding: URLEncoding.default)
        case .compareLectureWithFriend(let year, let semester, let memberIds):
            return .requestParameters(parameters: ["year": year, "semester": semester, "memberIds": memberIds], encoding: JSONEncoding.default)
        case .compareTimeWithFriend(year: let year, semester: let semester, memberIds: let memberIds):
            return .requestParameters(parameters: ["year": year, "semester": semester, "memberIds": memberIds], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getMyFriends:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .findPendingResponse:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .sendFriendRequest:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .acceptFriendRequest:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .rejectFriendRequest:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .deleteFriend:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .searchFriend:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .compareLectureWithFriend:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .compareTimeWithFriend:
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
