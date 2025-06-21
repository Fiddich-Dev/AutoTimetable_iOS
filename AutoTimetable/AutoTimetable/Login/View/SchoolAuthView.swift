//
//  SignUpView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/5/25.
//

import SwiftUI

struct SchoolAuthView: View {
    
    @State private var school: String = "성균관대학교"
    @State private var studentId: String = "201910914"
    @State private var password: String = "1234"
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ScrollView {
            Text("학교 계정으로 인증하기")
            
            TextField("학교 입력", text: $school)
                .focused($isFocused)
                .modifier(MyTextFieldModifier(isFocused: isFocused))
                .padding(.bottom, 8)
            
            
            TextField("학번만 입력", text: $studentId)
                .focused($isFocused)
                .modifier(MyTextFieldModifier(isFocused: isFocused))
                .padding(.bottom, 8)
                .keyboardType(.numberPad)
            
            SecureField("비밀번호 입력", text: $password)
                .focused($isFocused)
                .modifier(MyTextFieldModifier(isFocused: isFocused))
                .padding(.bottom, 68)
            
            Button(action: {
            
            }, label: {
                Text("로그인")
            })
            .padding(.bottom, 12)
        }
    }
}

#Preview {
    SchoolAuthView()
}
