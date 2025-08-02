//
//  SavedTimetableView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/26/25.
//

import SwiftUI

struct SavedYearAndSemesterView: View {
    
    @ObservedObject var timetableViewModel: TimetableViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // 저장된 학년도를 루프
                    ForEach(timetableViewModel.yearAndSemesters, id: \.self) { yearAndSemester in
                        // 해당 학년도의 시간표로 가는 버튼
                        NavigationLink(destination: SavedTimetableView(authViewModel: authViewModel, timetableViewModel: timetableViewModel), label: {
                            YearAndSemesterCell(year: yearAndSemester.year, semester: yearAndSemester.semester)
                        })
                        // 탭하면 뷰모델에 선택한 학년도 저장
                        .simultaneousGesture(TapGesture().onEnded {
                            timetableViewModel.selectedYear = yearAndSemester.year
                            timetableViewModel.selectedSemester = yearAndSemester.semester
                        })
                    }
                }
                .padding(.horizontal, 20)
            }
            .onAppear {
                // 저장된 학년도를 불러온다
                timetableViewModel.getYearAndSemester()
            }
            .toolbar {
                // 풀스크린 닫기
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
            }
        }
    }
}


//#Preview {
//    SavedYearAndSemesterView(timetableViewModel: TimetableViewModel())
//}
