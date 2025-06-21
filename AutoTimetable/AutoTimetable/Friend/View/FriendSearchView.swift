//
//  FiendSearchView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/13/25.
//

import SwiftUI

struct FriendSearchView: View {
    
    @State private var selectedSchool: School? = nil
    @State private var studentId: String = "201910914"
    @FocusState private var isFocused: FocusField?
    @ObservedObject var friendViewModel: FriendViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker("학교 선택", selection: $selectedSchool) {
                    // 아직 선택한 게 없을 때만 placeholder 표시
                    if selectedSchool == nil {
                        Text("학교를 선택하세요")
                            .tag(Optional<School>.none)
                    }
                    
                    ForEach(schoolList) { school in
                        Text(school.name).tag(Optional(school))
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .tint(Color.black)
                .padding(.bottom, 8)
                
                Text("학번")
                    .font(.title2)
                
                HStack {
                    
                    TextField("학번만 입력", text: $studentId)
                        .focused($isFocused, equals: .id)
                        .modifier(MyTextFieldModifier(isFocused: isFocused == .id))
                        .padding(.bottom, 8)
                        .keyboardType(.numberPad)
                    
                    Button(action: {
                        friendViewModel.searchFriend(school: selectedSchool?.name ?? "학교 오류", studentId: studentId)
                    }, label: {
                        Text("검색")
                    })
                }
                
                if let friend = friendViewModel.findFriend {
                    FriendCell(friend: friend, friendViewModel: friendViewModel)
                }
                
            }
            .padding(.horizontal, 20)
        }
    }
    
    enum FocusField: Hashable {
        case id
    }
}

struct FriendCell: View {
    
    var friend: Friend
    @ObservedObject var friendViewModel: FriendViewModel
    
    var body: some View {

            
        HStack {
            Image(systemName: "person.crop.circle")
            
            Text("\(friend.username)")
                .font(.title2)
            
            Spacer()
            
            Button(action: {
                friendViewModel.sendFriendRequest(receiverId: friend.id) {
                    
                }
            }, label: {
                Text("요청")
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

//#Preview {
//    FriendSearchView()
//}
