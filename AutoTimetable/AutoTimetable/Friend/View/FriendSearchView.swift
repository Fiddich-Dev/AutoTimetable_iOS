//
//  FiendSearchView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/13/25.
//

import SwiftUI
import Combine

struct FriendSearchView: View {
    
    @State private var studentId: String = ""
    @State private var searchStudentIdDebounced: String = ""
    @State private var debounceCancellable: AnyCancellable? = nil
    
    @FocusState private var isFocused: FocusField?
    @ObservedObject var friendViewModel: FriendViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("학번")
                    .font(.title2)
                
                HStack {
                    TextField("학번만 입력", text: $studentId)
                        .focused($isFocused, equals: .id)
                        .modifier(MyTextFieldModifier(isFocused: isFocused == .id))
                        .keyboardType(.numberPad)
                    
                    Button(action: {
                        friendViewModel.resetSearchState()
                        friendViewModel.searchFriend(studentId: studentId, page: 0, size: 20)
                    }, label: {
                        Text("검색")
                    })
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(studentId.count < 4 ? Color.gray.opacity(0.5) : Color.blue, lineWidth: 1)
                    )
                    .disabled(studentId.count < 4)
                }
                
                ForEach(friendViewModel.findFriends.indices, id: \.self) { index in
                    LazyVStack(spacing: 0) {
                        var friend = friendViewModel.findFriends[index]
                        
                        FriendCell(friend: .constant(friend), action: {
                            friendViewModel.sendFriendRequest(receiverId: friend.id) {
                                if let index = friendViewModel.findFriends.firstIndex(where: { $0.id == friend.id }) {
                                    friendViewModel.findFriends[index].status = .pending
                                }
                            }
                        })
                        .onAppear {
                            if(index == friendViewModel.findFriends.count - 3) {
                                if(!friendViewModel.isSearchFriendsLoading && !friendViewModel.isSearchFriendsLastPage) {
                                    friendViewModel.searchFriendsPage += 1
                                    
                                    friendViewModel.searchFriend(studentId: studentId, page: friendViewModel.searchFriendsPage, size: 20)
                                }
                            }
                        }
                        
//                        Divider()
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .onDisappear {
            friendViewModel.findFriends = []
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("친구 찾기")
        .navigationBarTitleDisplayMode(.inline)
    
    }
    
    enum FocusField: Hashable {
        case id
    }
}

struct FriendCell: View {
    
    @Binding var friend: SearchMemberDTO
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle")
            
            Text("\(friend.username)")
                .font(.title2)
            
            Spacer()
            if(friend.status == .alreadyFriend) {
                Text("친구")
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .foregroundStyle(.green)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.green, lineWidth: 1)
                    )
            }
            else if(friend.status == .pending) {
                Text("대기중")
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .foregroundStyle(.gray)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
            else {
                Button(action: {
                    action()
                }, label: {
                    Text("요청")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .foregroundStyle(.blue)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                })
            }
        }
    }
}

//#Preview {
//    FriendSearchView(friendViewModel: FriendViewModel())
//}
