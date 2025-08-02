//
//  FriendListVIew.swift
//  AutoTimetable
//
//  Created by 황인성 on 7/9/25.
//

import SwiftUI

struct FriendListView: View {
    
    @State var deleteId: Int64 = 0;
    @State var showAlert: Bool = false;
    
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
                        showAlert = true
                        deleteId = friend.id
                        
                    }, label: {
                        Text("삭제")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
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
        .alert("정말 삭제할까요?", isPresented: $showAlert) {
            Button("삭제", role: .destructive) {
                friendViewModel.deleteFriend(friendId: deleteId) {
                    friendViewModel.getMyFriends()
                }
            }
            Button("취소", role: .cancel) { }
        }
    }
}


struct PendingListView: View {
    
    @State var deleteId: Int64 = 0;
    @State var showAlert: Bool = false;
    
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
                            .foregroundStyle(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.blue)
                            )
                    })
                    
                    Button(action: {
                        showAlert = true
                        deleteId = pendingFriend.id
                    }, label: {
                        Text("삭제")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
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
        .alert("정말 삭제할까요?", isPresented: $showAlert) {
            Button("삭제", role: .destructive) {
                friendViewModel.rejectFriendRequest(requesterId: deleteId) {
                    friendViewModel.findPendingResponse()
                }
            }
            Button("취소", role: .cancel) { }
        }
    }
}
