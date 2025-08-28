//
//  SettingView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/6/25.
//

import SwiftUI

struct SettingView: View {
    @State private var showLogoutAlert = false
    @State private var showWithdrawAlert = false
    
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
            List {
                Section(header: Text("계정")) {
                    NavigationLink("비밀번호 변경") {
                        ChangePasswordView()
                    }
                    .foregroundColor(.blue)
                    
                    Button("로그아웃") {
                        showLogoutAlert = true
                    }
                    .foregroundColor(.blue)
                    
                    Button("회원탈퇴") {
                        showWithdrawAlert = true
                    }
                    .foregroundColor(.red)
                }

                Section(header: Text("고객지원")) {
                    Button(action: {
                        let kakaoAppURL = URL(string: "kakaotalk://")!
                        let kakaoOpenChatURL = URL(string: "https://open.kakao.com/o/sBrj8ZKh")!

                        if UIApplication.shared.canOpenURL(kakaoAppURL) {
                            // 카카오톡 설치되어 있으면 open.kakao.com도 앱에서 실행됨
                            UIApplication.shared.open(kakaoOpenChatURL)
                        } else {
                            // 설치 안 되어 있으면 Safari에서 열기
                            UIApplication.shared.open(kakaoOpenChatURL)
                        }
                    }) {
                        HStack {
                            Image(systemName: "message")
                            Text("1:1 문의")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .alert("로그아웃 하시겠습니까?", isPresented: $showLogoutAlert) {
                Button("로그아웃", role: .destructive) {
                    authViewModel.logout()
                    print("로그아웃 실행")
                }
                Button("취소", role: .cancel) { }
            }
            .alert("정말로 회원탈퇴 하시겠습니까?", isPresented: $showWithdrawAlert) {
                Button("회원탈퇴", role: .destructive) {
                    authViewModel.withdraw()
                    print("회원탈퇴 실행")
                }
                Button("취소", role: .cancel) { }
            }
    }
}

struct ChangePasswordView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    @State private var isVerified = false
    @State private var isPasswordValid: Bool = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var passwordsMatch: Bool = false
    @State private var passwordError = ""
    
    var body: some View {
        Form {
            Section(header: Text("현재 비밀번호")) {
                SecureField("현재 비밀번호", text: $currentPassword)
                Button("인증하기") {
                    authViewModel.passwordValid(password: currentPassword) { isValid in
                        if(isValid) {
                            isVerified = true
                        }
                        else {
                            showError = true
                            errorMessage = "비밀번호가 일치하지 않습니다."
                        }
                    }
                }
            }
            
            if isVerified {
                Section(header: Text("새 비밀번호")) {
                    SecureField("새 비밀번호", text: $newPassword)
                    SecureField("비밀번호 확인", text: $confirmPassword)
                    Button("비밀번호 변경") {
                        authViewModel.passwordChange(password: newPassword) {
                            dismiss()
                        }
                    }
                    .disabled(disabledCondition())
                }
            }
        }
        .navigationTitle("비밀번호 변경")
        .onChange(of: newPassword) { _ in
            validatePasswords()
            confirmPasswordMatch()
        }
        .onChange(of: confirmPassword) { _ in
            confirmPasswordMatch()
        }
        .alert("오류", isPresented: $showError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // 비밀번호 규칙 맞는지 확인
    func validatePasswords() {
        if !passwordMeetsCriteria(newPassword) {
            isPasswordValid = false
        } else {
            isPasswordValid = true
        }
    }
    // 재입력 비밀번호가 맞는지
    func confirmPasswordMatch() {
        if newPassword == confirmPassword {
            passwordError = ""
            passwordsMatch = true
        } else {
            passwordError = "비밀번호가 일치하지 않습니다"
            passwordsMatch = false
        }
    }
    // 비밀번호 규칙
    func passwordMeetsCriteria(_ password: String) -> Bool {
        let containsNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        let containsLetter = password.rangeOfCharacter(from: .letters) != nil
        let count = password.count >= 6
        
        return containsNumber && containsLetter && count
    }
    // 회원가입 버튼 활성화 조건
    func disabledCondition() -> Bool {
        let disabled = !isPasswordValid || !passwordsMatch
        return disabled
    }
    
}



//#Preview {
//    SettingView()
//}
