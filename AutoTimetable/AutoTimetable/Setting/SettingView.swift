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
                        let kakaoOpenChatURL = URL(string: "https://open.kakao.com/o/sbrJP8Fh")!

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
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    @State private var isVerified = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        Form {
            Section(header: Text("현재 비밀번호")) {
                SecureField("현재 비밀번호", text: $currentPassword)
                Button("인증하기") {
                    verifyCurrentPassword()
                }
            }
            
            if isVerified {
                Section(header: Text("새 비밀번호")) {
                    SecureField("새 비밀번호", text: $newPassword)
                    SecureField("비밀번호 확인", text: $confirmPassword)
                    Button("비밀번호 변경") {
                        changePassword()
                    }
                }
            }
        }
        .navigationTitle("비밀번호 변경")
        .alert("오류", isPresented: $showError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - 인증 로직 예시
    private func verifyCurrentPassword() {
        // 여기에 실제 인증 로직 (예: API 호출) 추가
        if currentPassword == "test1234" { // 임시 예시
            isVerified = true
        } else {
            errorMessage = "현재 비밀번호가 올바르지 않습니다."
            showError = true
        }
    }
    
    // MARK: - 비밀번호 변경 로직 예시
    private func changePassword() {
        guard !newPassword.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "새 비밀번호를 모두 입력해주세요."
            showError = true
            return
        }
        guard newPassword == confirmPassword else {
            errorMessage = "비밀번호가 일치하지 않습니다."
            showError = true
            return
        }
        // 실제 비밀번호 변경 API 호출 예시
        print("비밀번호 변경 완료")
    }
}



//#Preview {
//    SettingView()
//}
