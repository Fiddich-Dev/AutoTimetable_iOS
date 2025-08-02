//
//  CreateTimetableView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/24/25.
//

import SwiftUI

struct CreateTimetableView: View {
    
    @ObservedObject var timetableViewModel: TimetableViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            
            VStack {
                Text("시간표 생성 방식을\n선택해주세요")
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .padding(.vertical, 30)
                
                HStack {
                    // 에타 매핑뷰
                    NavigationLink(destination: EveryTimeMappingView(authViewModel: authViewModel), label: {
                        CardLabel(systemName: "square.and.arrow.down", description: "에타에서 가져오기", color: .orange)
                    })
                    // 커스텀 생성뷰
                    NavigationLink(destination: CustomCreateTimetableView(authViewModel: authViewModel, isPresented: $isPresented), label: {
                        CardLabel(systemName: "pencil.and.outline", description: "커스텀 생성", color: .green)
                    })
                }
                // 자동생성 뷰
                NavigationLink(destination: AutoCreateTimetableView(authViewModel: authViewModel, isPresented: $isPresented), label: {
                    CardLabel(systemName: "sparkles", description: "자동 생성", color: .blue)
                })
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .onAppear {
                // 사용중인 시간 비우기
                timetableViewModel.usedTime = Array(repeating: Array(repeating: 0, count: 1440), count: 7)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresented = false
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
            }
        }
        
    }
}


struct CardLabel: View {
    
    let systemName: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: systemName)
                .font(.largeTitle)
                .foregroundColor(color)
            Text(description)
                .foregroundColor(color)
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}


//#Preview {
//    CreateTimetableView(timetableViewModel: TimetableViewModel(), isPresented: .constant(true))
//}
