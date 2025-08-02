//
//  HomeView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/6/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject var timetableViewModel: TimetableViewModel
    @State private var todaysLectures: [LectureTimeInfo] = []
    
    init(authViewModel: AuthViewModel) {
        _timetableViewModel = StateObject(wrappedValue: TimetableViewModel(viewModel: authViewModel))
    }
    
    var body: some View {
        ZStack {
            if(timetableViewModel.isLoading) {
                ProgressView()
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    if !todaysLectures.isEmpty {
                        VStack(alignment: .leading) {
                            Text("오늘의 강의")
                                .font(.title2.bold())
                                .padding(.horizontal)
                            
                            ForEach(todaysLectures, id: \.self.id) { item in
                                LectureCardView(lectureInfo: item)
                            }
                        }
                    } else {
                        Text("오늘은 강의가 없습니다")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .refreshable {
                refreshData()
            }
            .onAppear {
                refreshData()
            }
            .onReceive(timetableViewModel.$mainTimetable) { _ in
                updateTodaysLectures()
            }
        }
    }
    
    private func refreshData() {
        let year = timetableViewModel.currentYear
        let semester = timetableViewModel.currentSemester
        timetableViewModel.getMainTimetableByYearAndSemester(year: year, semester: semester) {
            if let lectures = timetableViewModel.mainTimetable?.lectures {
                self.todaysLectures = getSortedTodaysLectures(lectures: lectures)
            } else {
                self.todaysLectures = []
            }
        }
    }
    private func updateTodaysLectures() {
        if let mainTimetable = timetableViewModel.mainTimetable {
            todaysLectures = getSortedTodaysLectures(lectures: mainTimetable.lectures)
        } else {
            todaysLectures = []
        }
    }
    
    private func getSortedTodaysLectures(lectures: [Lecture]) -> [LectureTimeInfo] {
        let today = Date().koreanWeekday() // 오늘 요일 첫 글자 (예: "월", "화", ...)
        
        return lectures
            .flatMap { $0.lectureTimeInfos(forWeekday: today) }
            .sorted { $0.startTime < $1.startTime }
    }
}




//#Preview {
//    HomeView()
//}
