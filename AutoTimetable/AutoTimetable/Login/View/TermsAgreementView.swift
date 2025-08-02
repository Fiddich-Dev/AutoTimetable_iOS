//
//  TermsAgreementView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/5/25.
//

import SwiftUI

struct TermsAgreementView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isPrivacyPolicyAccepted = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Button(action: {
                    isPrivacyPolicyAccepted.toggle()
                }) {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: isPrivacyPolicyAccepted ? "checkmark.square.fill" : "square")
                            .foregroundColor(isPrivacyPolicyAccepted ? .blue : .primary)
                        
                        Text("개인정보 처리방침에 동의합니다")
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
            }
            .padding(.vertical)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Group {
                        Text("개인정보 처리방침").font(.title2).bold()
                        Text("최종 업데이트: 2025년 8월 1일")
                        
                        Text("""
                            본 개인정보 처리방침은 당사 서비스 이용 시 귀하의 정보 수집, 사용 및 공개에 대한 당사의 정책과 절차를 설명하며, 귀하의 개인정보 보호 권리와 법률이 귀하를 보호하는 방법에 대해 알려드립니다.
                            
                            당사는 서비스를 제공하고 개선하기 위해 귀하의 개인정보를 사용합니다. 서비스를 이용함으로써 귀하는 본 개인정보 처리방침에 따라 정보가 수집되고 사용되는 것에 동의하는 것입니다.
                            """)
                    }
                    
                    Group {
                        Text("1. 수집하는 개인정보의 종류").font(.title3).bold()
                        Text("""
                            - 이메일 주소
                            - 이름 및 성
                            - 사용 데이터 (자동 수집되는 정보)
                            - 기기 정보 (IP 주소, 브라우저 유형 등)
                            - 카메라 및 사진 라이브러리 접근 (사용자 허가 시)
                            """)
                    }
                    
                    Group {
                        Text("2. 개인정보의 사용 목적").font(.title3).bold()
                        Text("""
                            - 서비스 제공 및 유지
                            - 계정 관리
                            - 서비스 개선 및 개발
                            - 고객 문의 응대
                            - 법적 의무 준수
                            """)
                    }
                    
                    Group {
                        Text("3. 개인정보의 보유 및 파기").font(.title3).bold()
                        Text("""
                            귀하의 개인정보는 수집 목적이 달성되면 지체 없이 파기됩니다. 단, 관련 법령에 따라 일정 기간 보관될 수 있습니다.
                            """)
                    }
                    
                    Group {
                        Text("4. 문의하기").font(.title3).bold()
                        Text("""
                            개인정보 처리방침에 관한 질문이 있으시면 아래로 연락주세요:
                            이메일: schedule.ssku@gmail.com
                            """)
                    }
                }
                .padding()
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
            
            Spacer()
            
            NavigationLink(destination: SignUpView(), label: {
                Text("동의하고 계속하기")
                    .modifier(MyButtonModifier(isDisabled: !isPrivacyPolicyAccepted))
            })
        }
        .navigationTitle("개인정보 처리방침")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }
}

#Preview {
    TermsAgreementView()
}
