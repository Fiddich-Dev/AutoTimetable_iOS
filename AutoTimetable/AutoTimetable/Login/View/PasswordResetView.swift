//
//  PasswordResetView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/5/25.
//

import SwiftUI

struct PasswordResetView: View {
    
    @State private var studentId: String = ""
    @State private var isAuthCodeSent: Bool = false
    @State private var authCode = ""
    @State private var isAuthCodeValid: Bool = false
    
    @State private var password = ""
    @State private var isPasswordValid: Bool = false
    @State private var confirmPassword = ""
    @State private var passwordsMatch: Bool = false
    @State private var passwordError = ""
    
    @FocusState private var isFocused: FocusField?
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        
        
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Text("본인인증")
                    .font(.largeTitle)
                
                Text("학번")
                    .font(.title2)
                
                HStack{
                    TextField("학번 입력", text: $studentId)
                        .frame(maxWidth: .infinity)
                        .focused($isFocused, equals: .studentId)
                        .modifier(MyTextFieldModifier(isFocused: isFocused == .studentId))
                        .disabled(isAuthCodeSent)
                    
                    Button(action: {
                        authViewModel.checkDuplicatedMember(studentId: studentId) { isDuplicated in
                            if(isDuplicated) {
                                authViewModel.mailSend(email: studentIdToEmail(studentId: studentId)) {
                                    isAuthCodeSent = true
                                }
                            }
                            else {
                                authViewModel.showAlert = true
                                authViewModel.alertMessage = "존재하지 않는 학번입니다."
                            }
                        }
                    }, label: {
                        Text("인증번호 전송")
                    })
                    .modifier(MyButtonModifier(isDisabled: isAuthCodeSent || studentId.isEmpty))
                    .frame(maxWidth: 120)
                }
                
                if(isAuthCodeSent) {
                    Text("\(studentIdToEmail(studentId: studentId))로 인증번호가 전송되었습니다")
                    
                    HStack{
                        TextField("인증번호 입력", text: $authCode)
                            .frame(maxWidth: .infinity)
                            .focused($isFocused, equals: .authCode)
                            .modifier(MyTextFieldModifier(isFocused: isFocused == .authCode))
                            .disabled(isAuthCodeValid)
                        
                        Button(action: { 
                            authViewModel.mailVerify(email: studentIdToEmail(studentId: studentId), authCode: authCode) { isVerified in
                                if(isVerified) {
                                    isAuthCodeValid = true
                                }
                                else {
                                    authViewModel.showAlert = true
                                    authViewModel.alertMessage = "인증번호가 틀렸습니다"
                                }
                            }
                        }, label: {
                            Text("인증번호 확인")
                        })
                        .modifier(MyButtonModifier(isDisabled: isAuthCodeValid || authCode.isEmpty))
                        .frame(maxWidth: 120)
                    }
                }
                
                if(isAuthCodeValid) {
                    Text("비밀번호 재설정")
                        .font(.title2)
                    
                    SecureField("비밀번호", text: $password)
                        .focused($isFocused, equals: .password)
                        .modifier(MyTextFieldModifier(isFocused: isFocused == .password))
                    
                    SecureField("비밀번호 재입력", text: $confirmPassword)
                        .focused($isFocused, equals: .confirmPassword)
                        .modifier(MyTextFieldModifier(isFocused: isFocused == .confirmPassword))
                    
                    Text("비밀번호는 숫자/영문자 혼합 6자 이상으로 작성해 주세요.")
                        .font(.caption)
                        .foregroundColor(isPasswordValid == false ? .red : Color.blue)
                    
                    Text(passwordError)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding(.bottom, 16)
                    
                    Button(action: {
                        authViewModel.passwordReset(studentId: studentId, newPassword: password) {
                            dismiss()
                        }
                    }, label: {
                        Text("확인")
                    })
                    .modifier(MyButtonModifier(isDisabled: !isPasswordValid || !passwordsMatch))
                }
            }
            .padding(.horizontal, 20)
            .onChange(of: password) { _ in
                validatePasswords()
                confirmPasswordMatch()
                print(isPasswordValid)
            }
            .onChange(of: confirmPassword) { _ in
                confirmPasswordMatch()
                print(passwordsMatch)
            }
            .alert(authViewModel.alertMessage, isPresented: $authViewModel.showAlert) {
                        Button("확인", role: .cancel) { }
                    }
            .scrollDismissesKeyboard(.interactively)
        }
    }
    
    // 비밀번호 규칙 맞는지 확인
    func validatePasswords() {
        if !passwordMeetsCriteria(password) {
            isPasswordValid = false
        } else {
            isPasswordValid = true
        }
    }
    // 재입력 비밀번호가 맞는지
    func confirmPasswordMatch() {
        if password == confirmPassword {
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
    
    enum FocusField: Hashable {
        case school
        case studentId
        case authCode
        case password
        case confirmPassword
    }
    
}

#Preview {
    PasswordResetView()
}

