//
//  FriendViewModel.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/10/25.
//

import Foundation
import Moya

class FriendViewModel: ObservableObject {
    
    private var provider: MoyaProvider<FriendApi>!
    
    @Published var myFriends: [Friend] = []
    @Published var pendingFriends: [Friend] = []
    @Published var findFriend: Friend?
    
    init() {
        self.provider = MoyaProvider<FriendApi>()
    }
    
    func getMyFriends() {
        provider.request(.getMyFriends) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print(response)
                    if let apiResponse = try? response.map(ApiResponse<[Friend]>.self), let friends = apiResponse.content {
                        
                        self.myFriends = friends
                        print("getMyFriends매핑 성공🚨")
                    }
                    else {
                        print("getMyFriends매핑 실패🚨")
                    }
                case .failure:
                    print("getMyFriends네트워크 요청 실패🚨")
                }
            }
        }
    }
    
    func findPendingResponse() {
        provider.request(.findPendingResponse) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print(response)
                    if let apiResponse = try? response.map(ApiResponse<[Friend]>.self), let pendingFriends = apiResponse.content {
                        
                        self.pendingFriends = pendingFriends
                        print("findPendingResponse매핑 성공🚨")
                    }
                    else {
                        print("findPendingResponse매핑 실패🚨")
                    }
                case .failure:
                    print("findPendingResponse네트워크 요청 실패🚨")
                }
            }
        }
    }
    
    func rejectFriendRequest(requesterId: Int64, completion: @escaping () -> Void) {
        provider.request(.rejectFriendRequest(requesterId: requesterId)) { result in
            DispatchQueue.main.async {
                if case .success(let response) = result,
                   let apiResponse = try? response.map(ApiResponse<EmptyContent>.self),
                   apiResponse.statusCode.uppercased() == "OK" {
                    print("✅ rejectFriendRequest 성공: \(apiResponse.message)")
                    completion()
                } else {
                    print("❌ rejectFriendRequest 실패 또는 매핑 실패")
                }
            }
        }
    }
    
    func acceptFriendRequest(requesterId: Int64, completion: @escaping () -> Void) {
        provider.request(.acceptFriendRequest(requesterId: requesterId)) { result in
            DispatchQueue.main.async {
                if case .success(let response) = result,
                   let apiResponse = try? response.map(ApiResponse<EmptyContent>.self),
                   apiResponse.statusCode.uppercased() == "OK" {
                    print("✅ acceptFriendRequest 성공: \(apiResponse.message)")
                    completion()
                } else {
                    print("❌ acceptFriendRequest 실패 또는 매핑 실패")
                }
            }
        }
    }
    
    func deleteFriend(friendId: Int64, completion: @escaping () -> Void) {
        provider.request(.deleteFriend(friendId: friendId)) { result in
            DispatchQueue.main.async {
                if case .success(let response) = result,
                   let apiResponse = try? response.map(ApiResponse<EmptyContent>.self),
                   apiResponse.statusCode.uppercased() == "OK" {
                    print("✅ deleteFriend 성공: \(apiResponse.message)")
                    completion()
                } else {
                    print("❌ deleteFriend 실패 또는 매핑 실패")
                }
            }
        }
    }
    
    func searchFriend(school: String, studentId: String) {
        provider.request(.searchFriend(school: school, studentId: studentId)) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    print(response)
                    if let apiResponse = try? response.map(ApiResponse<Friend>.self), let findFriend = apiResponse.content {
                        
                        self.findFriend = findFriend
                        print("searchFriend매핑 성공🚨")
                    }
                    else {
                        print("searchFriend매핑 실패🚨")
                    }
                case .failure:
                    print("searchFriend네트워크 요청 실패🚨")
                }
            }
        }
    }
    
    func sendFriendRequest(receiverId: Int64, completion: @escaping () -> Void) {
        provider.request(.sendFriendRequest(receiverId: receiverId)) { result in
            DispatchQueue.main.async {
                if case .success(let response) = result,
                   let apiResponse = try? response.map(ApiResponse<EmptyContent>.self),
                   apiResponse.statusCode.uppercased() == "OK" {
                    print("✅ sendFriendRequest 성공: \(apiResponse.message)")
                    completion()
                } else {
                    print("❌ sendFriendRequest 실패 또는 매핑 실패")
                }
            }
        }
    }
}
