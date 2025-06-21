//
//  SwiftUIView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/5/25.
//

import SwiftUI

struct FriendView: View {
    @State var selectedTab: Tab = .friend
    @StateObject var friendViewModel = FriendViewModel()
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                
                Text("시간표")
                
                HStack {
                    
                    Button(action: {

                    }, label: {
                        Text("시간표 비교하기")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .foregroundStyle(.blue)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    })
                    
                    Button(action: {

                    }, label: {
                        Text("공강 비교하기")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .foregroundStyle(.green)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.green, lineWidth: 1)
                            )
                    })
                    
                    
                }
                
                HStack {
                    
                    NavigationLink(destination: FriendSearchView(friendViewModel: friendViewModel), label: {
                        Image(systemName: "person.crop.circle.fill.badge.plus")
                    })
                    
                    
                    Image(systemName: "minus.circle")
                    
                    Image(systemName: "tablecells")
                }
                
                Picker("탭 선택", selection: $selectedTab) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Spacer()
                
                switch selectedTab {
                case .friend:
                    FriendListView(friendViewModel: friendViewModel)
                case .pending:
                    PendingListView(friendViewModel: friendViewModel)
                }
                
                Spacer()
            }
            
        }
        
    }
    
    
    enum Tab: String, CaseIterable {
        case friend = "친구"
        case pending = "대기"
    }}

struct FriendListView: View {
    
    @ObservedObject var friendViewModel: FriendViewModel;
    
    var body: some View {
        VStack {
            
            ForEach(friendViewModel.myFriends, id: \.self) { friend in
                HStack {
                    Image(systemName: "person.crop.circle")
                    
                    Text("\(friend.username)")
                        .font(.title2)
                    
                    Spacer()
                    
                    Button(action: {
                        friendViewModel.deleteFriend(friendId: friend.id) {
                            friendViewModel.getMyFriends()
                        }
                    }, label: {
                        Text("삭제")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
    //                        .padding()
                            .foregroundStyle(.red)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                    })
                    
                    
                    
                }
            }
            

        }
        .padding()
        .onAppear {
            friendViewModel.getMyFriends()
        }
    }
    
}

struct RedButtonModifier: ViewModifier {
    
    
    func body(content: Content) -> some View{
        content
            .foregroundStyle(Color.white)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
//            .background(isDisabled ? Color.gray.opacity(0.5) : Color.blue)
            .cornerRadius(20)
    }
}

//private Long id;
//
//private String studentId;
//private String profileImage;
//private String username;
//private String school;
//private String department;

struct PendingListView: View {
    
    @ObservedObject var friendViewModel: FriendViewModel;
    
    var body: some View {
        VStack {
            
            ForEach(friendViewModel.pendingFriends, id: \.self) { pendingFriend in
                
                HStack {
                    Image(systemName: "person.crop.circle")
                    
                    Text("\(pendingFriend.username)")
                        .font(.title2)
                    
                    Spacer()
                    
                    Button(action: {
                        friendViewModel.acceptFriendRequest(requesterId: pendingFriend.id) {
                            friendViewModel.getMyFriends()
                            friendViewModel.findPendingResponse()
                            
                        }
                    }, label: {
                        Text("수락")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                        //                        .padding()
                            .foregroundStyle(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.blue)
                            )
                    })
                    
                    
                    Button(action: {
                        friendViewModel.rejectFriendRequest(requesterId: pendingFriend.id) {
                            friendViewModel.findPendingResponse()
                        }
                    }, label: {
                        Text("삭제")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                        //                        .padding()
                            .foregroundStyle(.red)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                    })
                    
                    
                    
                }
            }
        }
        .padding()
        .onAppear {
            friendViewModel.findPendingResponse()
        }
    }
}




#Preview {
    FriendView()
}

// 친구목록
// 받은친구목록
// 유저검색

