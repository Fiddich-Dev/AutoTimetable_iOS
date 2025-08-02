//
//  TimetableView2.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/12/25.
//

import SwiftUI
import Combine

struct TimetableTabView: View {
    
    @StateObject var timetableViewModel: TimetableViewModel
    @StateObject var generateTimetableViewModel: GenerateTimetableViewModel = GenerateTimetableViewModel()
    
    // 저장된 시간표 풀스크린
    @State private var savedTimetableFullScreen = false
    // 시간표 만들기 풀스크린
    @State private var makeTimetableFullScreen = false
    @State private var canEdit = false
    
    
    init(authViewModel: AuthViewModel) {
        _timetableViewModel = StateObject(wrappedValue: TimetableViewModel(viewModel: authViewModel))
    }
    
    var body: some View {
        ZStack {
            
            if(timetableViewModel.isLoading) {
                ProgressView()
                    .zIndex(1)
            }
            
            ScrollView {
                VStack(alignment: .leading) {
                    // 상단 버튼
                    HStack(spacing: 16) {
                        ActionCardButton(icon: "doc.text", title: "저장된 시간표", color: .green) {
                            savedTimetableFullScreen = true
                        }
                        
                        ActionCardButton(icon: "plus.circle", title: "시간표 만들기", color: .blue) {
                            makeTimetableFullScreen = true
                        }
                    }
                    
                    HStack {
                        Text("메인 시간표")
                            .font(.largeTitle)
                        
                        Spacer()
                        
                        // 메인 시간표가 있으면
                        if let mainTimetable = timetableViewModel.mainTimetable {
                            // 읽기모드 일때
                            if !canEdit {
                                Button(action: {
                                    canEdit = true
                                    timetableViewModel.fillUsedTimeAboutLecturesTime(lecturesTime: mainTimetable.lectures.map { $0.time })
                                }, label: {
                                    Text("편집")
                                })
                            }
                            // 편집모드 일때
                            else {
                                // 취소버튼
                                Button(action: {
                                    canEdit = false
                                    timetableViewModel.getMainTimetableByYearAndSemester(year: "2025", semester: "2"){}
                                }, label: {
                                    Text("취소")
                                })
                                .foregroundStyle(Color.red)
                                
                                // 완료버튼
                                Button(action: {
                                    canEdit = false
                                    timetableViewModel.putTimetableLectures(
                                        timetableId: mainTimetable.id,
                                        lectures: mainTimetable.lectures
                                    ) {
                                        timetableViewModel.getMainTimetableByYearAndSemester(year: "2025", semester: "2"){}
                                    }
                                }, label: {
                                    Text("완료")
                                })
                            }
                        }
                        
                    }
                    
                    // 시간표가 있으면 시간표 정보 표시
                    if let mainTimetable = timetableViewModel.mainTimetable {
                        
                        // 편집모드일때 강의검색바 추가
                        if(canEdit) {
                            // 편집모드가 되면 usedtime을 채운다
                            LectureSearchBarWithUsedtime(viewModel: generateTimetableViewModel, selectedLectures: Binding(
                                get: { timetableViewModel.mainTimetable?.lectures ?? [] },
                                set: { newValue in
                                    if timetableViewModel.mainTimetable != nil {
                                        timetableViewModel.mainTimetable!.lectures = newValue
                                    }
                                }
                            ), usedTime: $timetableViewModel.usedTime)
                        }
                        
                        let totalCredits = mainTimetable.lectures
                            .compactMap { Int($0.credit) }
                            .reduce(0, +)
                        
                        Text("학점: \(totalCredits)")
                        
                        EditableTimetableView(
                            lectures: Binding(
                                get: { timetableViewModel.mainTimetable?.lectures ?? [] },
                                set: { newValue in
                                    if timetableViewModel.mainTimetable != nil {
                                        timetableViewModel.mainTimetable?.lectures = newValue
                                    }
                                }
                            ),
                            canEdit: $canEdit,
                            isAlertPresented: false
                        )
                        .padding(.horizontal, -10)
                        .padding(.bottom, 20)
                    }
                    // 메인 시간표가 없으면 없다고 표시
                    else {
                        Text("메인 시간표가 없습니다.")
                    }
                }
                .padding(.horizontal, 20)
                .fullScreenCover(isPresented: $savedTimetableFullScreen) {
                    SavedYearAndSemesterView(timetableViewModel: timetableViewModel)
                }
                .fullScreenCover(isPresented: $makeTimetableFullScreen) {
                    CreateTimetableView(timetableViewModel: timetableViewModel, isPresented: $makeTimetableFullScreen)
                }
                .onAppear {
                    print("생김")
                    let year = timetableViewModel.currentYearSemester.year
                    let semester = timetableViewModel.currentYearSemester.semester
                    timetableViewModel.getMainTimetableByYearAndSemester(year: year, semester: semester){}
                }
                // 풀스크린 닫히면 메인시간표 새로고침
                .onChange(of: savedTimetableFullScreen) { isPresented in
                    if !isPresented {
                        let year = timetableViewModel.currentYearSemester.year
                        let semester = timetableViewModel.currentYearSemester.semester
                        timetableViewModel.getMainTimetableByYearAndSemester(year: year, semester: semester){}
                    }
                }
                // 풀스크린 닫히면 메인시간표 새로고침
                .onChange(of: makeTimetableFullScreen) { isPresented in
                    if !isPresented {
                        let year = timetableViewModel.currentYearSemester.year
                        let semester = timetableViewModel.currentYearSemester.semester
                        timetableViewModel.getMainTimetableByYearAndSemester(year: year, semester: semester){}
                    }
                }
            }
        }
    }
}


//#Preview {
//    TimetableView2()
//}

