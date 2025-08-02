//
//  FriendViewModel.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/10/25.
//

import Foundation
import Moya

// 응답확인하기
//let rawString = String(data: response.data, encoding: .utf8)
//print("서버 응답: \(rawString ?? "nil")")
//print(response)

class FriendViewModel: ObservableObject {
    
    private var provider: MoyaProvider<FriendApi>!
    
    // 현재 학년도
    var currentYear = ""
    var currentSemester = ""
    
    @Published var isLoading: Bool = false
    
    @Published var myFriends: [Friend] = []
    @Published var pendingFriends: [Friend] = []
    @Published var findFriends: [SearchMemberDTO] = []
    
    // 강의 검색 공통 페이징 옵션
    @Published var searchedFriends: [Lecture] = []
    @Published var isSearchFriendsLoading = false
    @Published var isSearchFriendsLastPage = false
    var searchFriendsPage: Int = 0
    
    
    @Published var selectedFriends: [Friend] = []
    @Published var compareTimetableDtos: [CompareTimetableDto] = []
    @Published var compareTimes: [Lecture] = []
    
    init(viewModel: AuthViewModel) {
        loadCurrentSemester()
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
                    
                    let rawString = String(data: response.data, encoding: .utf8)
                    print("서버 응답: \(rawString ?? "nil")")
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
    
    func searchFriend(studentId: String, page: Int, size: Int) {
        self.isLoading = true
        provider.request(.searchFriend(studentId: studentId, page: page, size: size)) { result in
            DispatchQueue.main.async {
                
                defer { self.isLoading = false }
                
                switch result {
                case .success(let response):
                    
                    let rawString = String(data: response.data, encoding: .utf8)
                    print("서버 응답: \(rawString ?? "nil")")
                    print(response)
                    
                    if let apiResponse = try? response.map(ApiResponse<[SearchMemberDTO]>.self), let findFriends = apiResponse.content {
                        
                        if(findFriends.isEmpty) {
                            self.isSearchFriendsLastPage = true
                            print("✅ 마지막 페이지")
                        } else {
                            self.findFriends.append(contentsOf: findFriends)
                            print("✅ searchFriend매핑 성공")
                        }
                    }
                    else {
                        print("🚨 searchFriend매핑 실패")
                        self.resetSearchState()
                    }
                case .failure:
                    print("🚨 searchFriend네트워크 요청 실패")
                    self.resetSearchState()
                }
            }
        }
    }
    
    func resetSearchState() {
        self.findFriends = []
        self.searchFriendsPage = 0
        self.isSearchFriendsLoading = false
        self.isSearchFriendsLastPage = false
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
    
    // MARK: 현재 학년도 가져오기
    private func loadCurrentSemester() {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        self.currentYear = String(year)

        switch month {
        case 1...6:
            self.currentSemester = "1"
        case 7...12:
            self.currentSemester = "2"
        default:
            self.currentSemester = "99"
        }
        
        print("\(self.currentYear)년 \(self.currentSemester)학기")
        
    }
    
    
}
