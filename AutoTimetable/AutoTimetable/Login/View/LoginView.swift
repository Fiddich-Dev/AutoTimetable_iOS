//
//  LoginView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/5/25.
//

import SwiftUI
import Combine

struct loadingView: View {
    var body: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
        
        VStack(spacing: 16) {
            ProgressView("잠시만 기다려 주세요...")
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .foregroundColor(.white)
        }
        .padding(20)
        .background(Color.black.opacity(0.7))
        .cornerRadius(12)
    }
}


struct LoginView: View {
    
    @State private var studentId: String = ""
    @State private var password: String = ""
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @FocusState private var isFocused: FocusField?
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("로그인")
                            .font(.largeTitle)
                        
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
                            NavigationLink(destination: PasswordResetView(), label: {
                                Text("계정 찾기")
                            })
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.6))
                                .frame(maxWidth: 1, maxHeight: 20)
                                .padding(.horizontal, 20)
                            
                            NavigationLink(destination: SignUpView(), label: {
                                Text("회원가입")
                            })
                        }
                        .frame(maxWidth: .infinity)
                        
                        Spacer()
                        
                        Button(action: {
                            authViewModel.login(studentId: studentId, password: password)
                        }, label: {
                            Text("로그인")
                        })
                        .modifier(MyButtonModifier(isDisabled: studentId.isEmpty || password.isEmpty))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                }
                .scrollDismissesKeyboard(.interactively)
                .alert(authViewModel.alertMessage, isPresented: $authViewModel.showAlert) {
                            Button("확인", role: .cancel) { }
                        }
            }
            
            if authViewModel.isLoading {
                loadingView()
            }
        }
    }
    
    enum FocusField: Hashable {
        case id
        case password
    }
}

#Preview {
    LoginView()
}
