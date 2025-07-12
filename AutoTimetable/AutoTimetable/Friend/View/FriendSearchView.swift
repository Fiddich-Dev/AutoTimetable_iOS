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
                Text("친구 찾기")
                    .font(.largeTitle)
                
                Text("학번")
                    .font(.title2)
                
                TextField("학번만 입력", text: $studentId)
                    .focused($isFocused, equals: .id)
                    .modifier(MyTextFieldModifier(isFocused: isFocused == .id))
                    .padding(.bottom, 8)
                    .keyboardType(.numberPad)
                
                ForEach(friendViewModel.findFriends, id: \.id) { friend in
                    FriendCell(friend: .constant(friend), action: {
                        friendViewModel.sendFriendRequest(receiverId: friend.id) {
                            if let index = friendViewModel.findFriends.firstIndex(where: { $0.id == friend.id }) {
                                friendViewModel.findFriends[index].status = .pending
                            }
                        }
                    })
                }

                
            }
            .padding(.horizontal, 20)
        }
        .onChange(of: studentId) { newValue in
            debounceCancellable?.cancel()
            debounceCancellable = Just(newValue)
                .delay(for: .milliseconds(500), scheduler: RunLoop.main)
                .sink { debouncedValue in
                    searchStudentIdDebounced = debouncedValue
                    if !debouncedValue.trimmingCharacters(in: .whitespaces).isEmpty {
                        friendViewModel.searchFriend(studentId: debouncedValue)
                    }
                }
        }
        .onDisappear {
            friendViewModel.findFriends = []
        }
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
