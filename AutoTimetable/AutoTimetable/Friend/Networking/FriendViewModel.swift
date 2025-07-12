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
    
    @Published var isLoading: Bool = false
    
    @Published var myFriends: [Friend] = []
    @Published var pendingFriends: [Friend] = []
    @Published var findFriends: [SearchMemberDTO] = []
    
    
    @Published var selectedFriends: [Friend] = []
    @Published var compareTimetableDtos: [CompareTimetableDto] = []
    @Published var compareTimes: [Lecture] = []
    
    init(viewModel: AuthViewModel) {
        let authPlugin = AuthPlugin(viewModel: viewModel)
        self.provider = MoyaProvider<FriendApi>(plugins: [authPlugin])
    }
    
    func getMyFriends() {
        self.isLoading = true
        provider.request(.getMyFriends) { result in
            DispatchQueue.main.async {
                
                defer { self.isLoading = false }
                
                switch result {
                case .success(let response):
                    print(response)
                    if let apiResponse = try? response.map(ApiResponse<[Friend]>.self), let friends = apiResponse.content {
                        
                        self.myFriends = friends
                        print("✅ getMyFriends매핑 성공")
                    }
                    else {
                        print("🚨 getMyFriends매핑 실패")
                    }
                case .failure:
                    print("🚨 getMyFriends네트워크 요청 실패")
                }
            }
        }
    }
    
    func findPendingResponse() {
        self.isLoading = true
        provider.request(.findPendingResponse) { result in
            DispatchQueue.main.async {
                
                defer { self.isLoading = false }
                
                switch result {
                case .success(let response):
                    print(response)
                    if let apiResponse = try? response.map(ApiResponse<[Friend]>.self), let pendingFriends = apiResponse.content {
                        
                        self.pendingFriends = pendingFriends
                        print("✅ findPendingResponse매핑 성공")
                    }
                    else {
                        print("🚨 findPendingResponse매핑 실패")
                    }
                case .failure:
                    print("🚨 findPendingResponse네트워크 요청 실패")
                }
            }
        }
    }
    
    func searchFriend(studentId: String) {
        self.isLoading = true
        provider.request(.searchFriend(studentId: studentId)) { result in
            DispatchQueue.main.async {
                
                defer { self.isLoading = false }
                
                switch result {
                case .success(let response):
                    print(response)
                    if let apiResponse = try? response.map(ApiResponse<[SearchMemberDTO]>.self), let findFriends = apiResponse.content {
                        
                        self.findFriends = findFriends
                        print("✅ searchFriend매핑 성공")
                    }
                    else {
                        print("🚨 searchFriend매핑 실패")
                    }
                case .failure:
                    print("🚨 searchFriend네트워크 요청 실패")
                }
            }
        }
    }
    
    func rejectFriendRequest(requesterId: Int64, completion: @escaping () -> Void) {
        self.isLoading = true
        provider.request(.rejectFriendRequest(requesterId: requesterId)) { result in
            DispatchQueue.main.async {
                
                defer { self.isLoading = false }
                
                switch result {
                case .success(let response):
                    if let apiResponse = try? response.map(ApiResponse<EmptyContent>.self) {
                        print("✅ rejectFriendRequest 매핑 성공")
                        completion()
                    }
                case .failure:
                    print("🚨 rejectFriendRequest 요청 실패")
                }
            }
        }
    }
    
    func acceptFriendRequest(requesterId: Int64, completion: @escaping () -> Void) {
        self.isLoading = true
        provider.request(.acceptFriendRequest(requesterId: requesterId)) { result in
            DispatchQueue.main.async {
                
                defer { self.isLoading = false }
                
                switch result {
                case .success(let response):
                    if let apiResponse = try? response.map(ApiResponse<EmptyContent>.self) {
                        print("✅ acceptFriendRequest 매핑 성공")
                        completion()
                    }
                case .failure:
                    print("🚨 acceptFriendRequest 요청 실패")
                }            }
        }
    }
    
    func deleteFriend(friendId: Int64, completion: @escaping () -> Void) {
        self.isLoading = true
        provider.request(.deleteFriend(friendId: friendId)) { result in
            DispatchQueue.main.async {
                
                defer { self.isLoading = false }
                
                switch result {
                case .success(let response):
                    if let apiResponse = try? response.map(ApiResponse<EmptyContent>.self) {
                        print("✅ deleteFriend 매핑 성공")
                        completion()
                    }
                case .failure:
                    print("🚨 deleteFriend 요청 실패")
                }
            }
        }
    }
    

    
    func sendFriendRequest(receiverId: Int64, completion: @escaping () -> Void) {
        self.isLoading = true
        provider.request(.sendFriendRequest(receiverId: receiverId)) { result in
            DispatchQueue.main.async {
                
                defer { self.isLoading = false }
                
                switch result {
                case .success(let response):
                    if let apiResponse = try? response.map(ApiResponse<EmptyContent>.self) {
                        print("✅ sendFriendRequest 매핑 성공")
                        completion()
                    }
                case .failure:
                    print("🚨 sendFriendRequest 요청 실패")
                }
            }
        }
    }
    
    func compareLectureWithFriend(year: String, semeser: String, memberIds: [Int64]) {
        self.isLoading = true
        provider.request(.compareLectureWithFriend(year: year, semester: semeser, memberIds: memberIds)) { result in
            DispatchQueue.main.async {
                
                defer { self.isLoading = false }
                
                switch result {
                case .success(let response):
                    print(response)
                    if let apiResponse = try? response.map(ApiResponse<[CompareTimetableDto]>.self), let compareTimetableDtos = apiResponse.content {
                        
                        self.compareTimetableDtos = compareTimetableDtos
                        print("✅ compareLectureWithFriend매핑 성공")
                    }
                    else {
                        print("🚨 compareLectureWithFriend매핑 실패")
                    }
                case .failure:
                    print("🚨 compareLectureWithFriend네트워크 요청 실패")
                }
            }
        }
    }
    
    func compareTimeWithFriend(year: String, semeser: String, memberIds: [Int64]) {
        self.isLoading = true
        provider.request(.compareTimeWithFriend(year: year, semester: semeser, memberIds: memberIds)) { result in
            DispatchQueue.main.async {
                
                defer { self.isLoading = false }
                
                switch result {
                case .success(let response):
                    print(response)
                    if let apiResponse = try? response.map(ApiResponse<[Lecture]>.self), let compareTimes = apiResponse.content {
                        
                        self.compareTimes = compareTimes
                        print("✅ compareTimeWithFriend매핑 성공")
                    }
                    else {
                        print("🚨 compareTimeWithFriend매핑 실패")
                    }
                case .failure:
                    print("🚨 compareTimeWithFriend네트워크 요청 실패")
                }
            }
        }
    }
    
    
}
