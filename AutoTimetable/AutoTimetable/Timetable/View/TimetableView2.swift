//
//  TimetableView2.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/12/25.
//

import SwiftUI
import Combine

struct TimetableView2: View {
    
    @StateObject var timetableViewModel: TimetableViewModel
    
    @State private var savedTimetableFullScreen = false
    @State private var makeTimetableFullScreen = false
    
    @State private var canEdit = false
    @State private var infoModalIsPresented = false
    
    @State private var isDeleteAlertPresented = false
    
    @State private var searchText: String = ""
    @State private var searchTextDebounced: String = ""
    @State private var debounceCancellable: AnyCancellable? = nil
    
    init(authViewModel: AuthViewModel) {
        _timetableViewModel = StateObject(wrappedValue: TimetableViewModel(viewModel: authViewModel))
    }
    
    var body: some View {
        
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
                    if(timetableViewModel.mainTimetable != nil) {
                        
                        // 읽기모드 일때
                        if(!canEdit) {
                            Button(action: {
                                // 편집모드로 전환
                                canEdit = true
                                
                                if let mainLecturesTime = timetableViewModel.mainTimetable?.lectures.map({ $0.time }) {
                                    timetableViewModel.fillUsedTimeAboutLecturesTime(lecturesTime: mainLecturesTime)
                                }
                                
                                
                            }, label: {
                                Text("편집")
                            })
                        }
                        // 편집모드 일떄
                        else {
                            // 취소버튼
                            Button(action: {
                                // 읽기모드로 전환
                                canEdit = false
                                // 메인시간표 새로고침
                                let year = timetableViewModel.currentYearSemester.year
                                let semester = timetableViewModel.currentYearSemester.semester
                                timetableViewModel.getMainTimetableByYearAndSemester(year: year, semester: semester)
                            }, label: {
                                Text("취소")
                            })
                            .foregroundStyle(Color.red)
                            
                            // 완료버튼
                            Button(action: {
                                canEdit = false
                                // 메인 시간표가 있으면
                                if let timetable = timetableViewModel.mainTimetable {
                                    // 메인시간표 업데이트후, 새로고침
                                    timetableViewModel.putTimetableLectures(
                                        timetableId: timetable.id,
                                        lectureIds: timetable.lectures.map(\.id)
                                    ) {
                                        let year = timetableViewModel.currentYearSemester.year
                                        let semester = timetableViewModel.currentYearSemester.semester
                                        timetableViewModel.getMainTimetableByYearAndSemester(year: year, semester: semester)
                                    }
                                } else {
                                    // 에러 alert 띄우기
                                    timetableViewModel.errorAlert = true
                                }
                            }, label: {
                                Text("완료")
                            })
                        }
                    }
                    
                }
                
                // 시간표가 있으면 시간표 정보 표시
                if let mainTimetable = timetableViewModel.mainTimetable {
                    let totalCredits = mainTimetable.lectures
                        .compactMap { Int($0.credit) }
                        .reduce(0, +)
                    
                    Text("학점: \(totalCredits)")
                }
                
                // 편집모드일때 강의검색바 추가
                if(canEdit) {
                    // 편집모드가 되면 usedtime을 채운다
                    LectureSearchBarWithUsedtime(searchText: $searchText,
                                                 selectedLectures: Binding(
                                                    get: { timetableViewModel.mainTimetable?.lectures ?? [] },
                                                    set: { newValue in
                                                        if timetableViewModel.mainTimetable != nil {
                                                            timetableViewModel.mainTimetable!.lectures = newValue
                                                        }
                                                    }
                                                 ), searchedLectures: $timetableViewModel.searchLectures, usedTime: $timetableViewModel.usedTime)
                    .zIndex(1)
                    
                    
                }
                
                // 메인 시간표가 없으면 없다고 표시
                if timetableViewModel.mainTimetable == nil {
                    Text("메인 시간표가 없습니다.")
                }
                // 메인 시간표가 있으면 시간표 표시
                else {
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
                        isAlertPresented: $isDeleteAlertPresented
                    )
                    .padding(.horizontal, -10)
                    .padding(.bottom, 20)
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
                // 메인시간표 가져오기
                print("생김")
                let year = timetableViewModel.currentYearSemester.year
                let semester = timetableViewModel.currentYearSemester.semester
                timetableViewModel.getMainTimetableByYearAndSemester(year: year, semester: semester)
            }
            // 풀스크린 닫히면 메인시간표 새로고침
            .onChange(of: savedTimetableFullScreen) { isPresented in
                if !isPresented {
                    let year = timetableViewModel.currentYearSemester.year
                    let semester = timetableViewModel.currentYearSemester.semester
                    timetableViewModel.getMainTimetableByYearAndSemester(year: year, semester: semester)
                }
            }
            // 풀스크린 닫히면 메인시간표 새로고침
            .onChange(of: makeTimetableFullScreen) { isPresented in
                if !isPresented {
                    let year = timetableViewModel.currentYearSemester.year
                    let semester = timetableViewModel.currentYearSemester.semester
                    timetableViewModel.getMainTimetableByYearAndSemester(year: year, semester: semester)
                }
            }
            .onChange(of: searchText) { newValue in
                debounceCancellable?.cancel()
                debounceCancellable = Just(newValue)
                    .delay(for: .milliseconds(500), scheduler: RunLoop.main)
                    .sink { debouncedValue in
                        searchTextDebounced = debouncedValue
                        timetableViewModel.searchLectures(keyword: debouncedValue)
                    }
            }
            
        }
        
    }
}


//#Preview {
//    TimetableView2()
//}

