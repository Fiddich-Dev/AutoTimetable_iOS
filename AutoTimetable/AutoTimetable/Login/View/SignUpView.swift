//
//  SignUpView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/5/25.
//

import SwiftUI

struct SignUpView: View {
    
    @State private var selectedSchool: School? = nil
    @State private var school = "ㅁ"
    @State private var studentId = ""
    @State private var authCode = ""
    @State private var isAuthCodeSent: Bool = false
    @State private var isAuthCodeValid: Bool = false
    
    @State private var password = ""
    @State private var isPasswordValid: Bool = false
    @State private var confirmPassword = ""
    @State private var passwordsMatch: Bool = false
    
    @State private var passwordError = ""
    @State private var name = ""
    @State private var department = ""
    @State private var grade = 0
    
    private var email = "hiws99@naver.com"
    
    
    @FocusState private var isFocused: FocusField?
    
    @State private var isSignUpComplete = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var authViewModel: AuthViewModel
    

    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("회원가입")
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
                
//                TextField("학교 입력", text: $school)
//                    .focused($isFocused, equals: .school)
//                    .modifier(MyTextFieldModifier(isFocused: isFocused == .school))
//                    .disabled(isAuthCodeSent)
                
                Text("학번")
                
                HStack{
                    TextField("학번 입력", text: $studentId)
                        .frame(maxWidth: .infinity)
                        .focused($isFocused, equals: .studentId)
                        .modifier(MyTextFieldModifier(isFocused: isFocused == .studentId))
                        .disabled(isAuthCodeSent)
                    
                    Button(action: {
                        
                        authViewModel.checkDuplicatedMember(school: selectedSchool?.name ?? "학교오류", studentId: studentId) { isDuplicated in
                            if(!isDuplicated) {
                                authViewModel.mailSend(email: email) {
                                    isAuthCodeSent = true
                                }
                            }
                            else {
                                // 이미 가입되어있음
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
                    Text("비밀번호")
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
                    
                    Text("이름")
                    TextField("이름 입력", text: $name)
                        .focused($isFocused, equals: .name)
                        .modifier(MyTextFieldModifier(isFocused: isFocused == .name))
                        .padding(.bottom, 8)
                    
                    Text("학과")
                    Picker(selection: $department, label: Text("department")) {
                        if department.isEmpty {
                            Text("선택").tag("")
                        }
                        Text("컴퓨터과학전공").tag("컴퓨터과학전공")
    //                        Text("융합전자공학과").tag("융합전자공학과")
                    }
                    
                    Text("학년")
                    Picker(selection: $grade, label: Text("grade")) {
                        if grade == 0 {
                            Text("선택").tag(0)
                        }
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                        Text("4").tag(4)
                    }
                    
                    
                    Spacer()
                    
                    Button(action: {
                        authViewModel.join(studentId: studentId, password: password, username: name, school: selectedSchool?.name ?? "학교오류", department: department) {
                            presentationMode.wrappedValue.dismiss()
                        }
                        
                        
                    }, label: {
                        Text("확인")
                    })
                    .modifier(MyButtonModifier(isDisabled: disabledCondition()))
                }
                

                
                
                

                
                
//                Button(action: {
//                    // 뷰의 변수를 뷰모델로 전달
//                    authViewModel.user.email = "\(authViewModel.user.studentId ?? "asd")@sangmyung.kr"
//                    authViewModel.user.password = password
//                    authViewModel.user.name = name
//                    authViewModel.user.nickname = nickname
//                    authViewModel.user.department = department
//                    authViewModel.user.grade = grade
//                    authViewModel.user.isPublic = isPublic
//                    // 회원가입
//                    authViewModel.signUp(user: authViewModel.user) {
//                        isSignUpComplete.toggle()
//                    }
//                }, label: {
//                    Text("확인")
//                        .modifier(MyButtonModifier(isDisabled: disabledCondition()))
//                })
//                .disabled(disabledCondition())
//                .padding(.bottom, 10)
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
    // 회원가입 버튼 활성화 조건
    func disabledCondition() -> Bool {
        let disabled = !isAuthCodeSent || !isPasswordValid || name.isEmpty || !passwordsMatch || department.isEmpty || grade == 0
        return disabled
    }
    
    enum FocusField: Hashable {
        case school
        case studentId
        case authCode
        case password
        case confirmPassword
        case name
        case department
        case grade
    }
}

#Preview {
    SignUpView()
}
