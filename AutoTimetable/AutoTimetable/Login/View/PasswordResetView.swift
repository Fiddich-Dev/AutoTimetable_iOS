//
//  PasswordResetView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/5/25.
//

import SwiftUI

struct PasswordResetView: View {
    
    @State private var selectedSchool: School? = nil
    @State private var school: String = "ㅁ"
    @State private var studentId: String = ""
    @State private var isAuthCodeSent: Bool = false
    
    @FocusState private var isFocused: FocusField?
    @EnvironmentObject var authViewModel: AuthViewModel
    private var email = "hiws99@naver.com"
    @State private var authCode = ""
    @State private var isAuthCodeValid: Bool = false
    
    @State private var password = ""
    @State private var isPasswordValid: Bool = false
    @State private var confirmPassword = ""
    @State private var passwordsMatch: Bool = false
    @State private var passwordError = ""
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        
        
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Text("본인인증")
                    .font(.title)
                
                Text("학교")
                
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
                .disabled(isAuthCodeSent)
                
                
                Text("학번")
                
                HStack{
                    TextField("학번 입력", text: $studentId)
                        .frame(maxWidth: .infinity)
                        .focused($isFocused, equals: .studentId)
                        .modifier(MyTextFieldModifier(isFocused: isFocused == .studentId))
                        .disabled(isAuthCodeSent)
                    
                    Button(action: {
                        authViewModel.checkDuplicatedMember(school: selectedSchool?.name ?? "학교오류", studentId: studentId) { isDuplicated in
                            if(isDuplicated) {
                                authViewModel.mailSend(email: email) {
                                    isAuthCodeSent = true
                                }
                            }
                            else {
                                // alert띄우기
                            }
                        }
                        
                        
                        
                    }, label: {
                        Text("인증번호 전송")
                    })
                    .modifier(MyButtonModifier(isDisabled: isAuthCodeSent || school.isEmpty || studentId.isEmpty))
                    .frame(maxWidth: 120)
                }
                
                if(isAuthCodeSent) {
                    Text("학교 웹메일로 인증번호가 전송되었습니다")
                    
                    HStack{
                        TextField("인증번호 입력", text: $authCode)
                            .frame(maxWidth: .infinity)
                            .focused($isFocused, equals: .authCode)
                            .modifier(MyTextFieldModifier(isFocused: isFocused == .authCode))
                            .disabled(isAuthCodeValid)
                        
                        
                        Button(action: {
                            authViewModel.mailVerify(email: email, authCode: authCode) {
                                isAuthCodeValid = true
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
                        authViewModel.passwordReset(school: selectedSchool?.name ?? "학교오류", studentId: studentId, newPassword: password) {
                            presentationMode.wrappedValue.dismiss()
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
            
            
//            VStack(spacing: 20) {
//                Text("비밀번호 재설정")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .padding(.top, 50)
//                
//                Text("가입한 학번을 입력하시면, 본인 인증 링크 보내드립니다.")
//                    .font(.body)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//                
//                TextField("학교 입력", text: $studentId)
//                    .focused($isFocused, equals: .school)
//                    .keyboardType(.numberPad)
//                    .modifier(MyTextFieldModifier(isFocused: isFocused == .school))
//                
//                TextField("학번 입력", text: $studentId)
//                    .focused($isFocused, equals: .studentId)
//                    .keyboardType(.numberPad)
//                    .modifier(MyTextFieldModifier(isFocused: isFocused == .studentId))
//                
//                
//                Button(action: {
//                    
//                }, label: {
//                    Text("임시비밀번호 보내기")
//                })
//                .modifier(MyButtonModifier(isDisabled: school.isEmpty || studentId.isEmpty))
//                .padding(.vertical, 30)
//                
//                Spacer()
//            }
//            .padding(.horizontal, 20)
            
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

// 학교메일 인증을 하면
// 비번 재설정 기회를 준다
