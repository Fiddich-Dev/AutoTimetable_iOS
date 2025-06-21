//
//  LoginView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/5/25.
//

import SwiftUI
import Combine


struct LoginView: View {
    
    @State private var selectedSchool: School? = nil
    @State private var school: String = "성균관대학교"
    @State private var studentId: String = "201910914"
    @State private var password: String = "1234"
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @FocusState private var isFocused: FocusField?
    
    
    var body: some View {
        
        NavigationView {
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("로그인")
                        .font(.largeTitle)
                    
                    Text("학교")
                        .font(.title2)
                    
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
                    
//                    
//                    TextField("학교 입력", text: $school)
//                        .focused($isFocused, equals: .school)
//                        .modifier(MyTextFieldModifier(isFocused: isFocused == .school))
//                        .padding(.bottom, 8)
                    
                    Text("학번")
                        .font(.title2)
                    
                    TextField("학번만 입력", text: $studentId)
                        .focused($isFocused, equals: .id)
                        .modifier(MyTextFieldModifier(isFocused: isFocused == .id))
                        .padding(.bottom, 8)
                        .keyboardType(.numberPad)
                    
                    Text("비밀번호")
                        .font(.title2)
                    
                    SecureField("비밀번호 입력", text: $password)
                        .focused($isFocused, equals: .password)
                        .modifier(MyTextFieldModifier(isFocused: isFocused == .password))
                        .padding(.bottom, 30)
                    
                    
                    HStack {
                        
                        NavigationLink {
                            PasswordResetView()
                        } label: {
                            Text("계정 찾기")
                        }
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.6))
                            .frame(maxWidth: 1, maxHeight: 20)
                            .padding(.horizontal, 20)
                        
                        
                        NavigationLink {
                            SignUpView()
                        } label: {
                            Text("회원가입")
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
                    
                    
                    Spacer()
                    
                    Button(action: {
                        authViewModel.login(school: school, studentId: studentId, password: password)
                    }, label: {
                        Text("로그인")
                    })
                    .modifier(MyButtonModifier(isDisabled: school.isEmpty || studentId.isEmpty || password.isEmpty))
                    
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
                .padding(.bottom, 10)
            }
            .scrollDismissesKeyboard(.interactively)
            
        }
        
    }
    
    enum FocusField: Hashable {
        case school
        case id
        case password
    }
}

struct MyTextFieldModifier: ViewModifier {
    var isFocused: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: isFocused ? 0.7 : 0.1)
            )
    }
}

struct MyButtonModifier: ViewModifier {
    
    var isDisabled: Bool
    
    func body(content: Content) -> some View{
        content
            .foregroundStyle(Color.white)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(isDisabled ? Color.gray.opacity(0.5) : Color.blue)
            .cornerRadius(20)
    }
}





#Preview {
    LoginView()
}
