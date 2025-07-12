//
//  CustomCreateTimetableView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/27/25.
//

import SwiftUI
import Combine

struct CustomCreateTimetableView: View {
    
    @StateObject var viewModel = GenerateTimetableViewModel()
    
    @Binding var isPresented: Bool
    
    // 검색에 필요
    @State private var searchText: String = ""
    @State private var searchTextDebounced: String = ""
    @State private var debounceCancellable: AnyCancellable? = nil
    
    @State private var canEdit: Bool = true
    @State private var isDeleteAlertPresented: Bool = false
    
    // 메인시간표로 저장할지
    @State private var isMainTimetableSet: Bool = false
    
    @State var showAlert: Bool = false
    @State var alertMessage: String = ""
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // 메인시간표로 설정버튼
                HStack {
                    Button(action: {
                        isMainTimetableSet.toggle()
                    }, label: {
                        if(isMainTimetableSet) {
                            Image(systemName: "checkmark.square")
                        }
                        else {
                            Image(systemName: "square")
                        }
                    })
                        
                    Text("메인 시간표로 설정")
                }
                .font(.title2)
                
                // 강의 추가, 삭제 바
                LectureSearchBarWithUsedtime(searchText: $searchText, selectedLectures: $viewModel.customTimetable, searchedLectures: $viewModel.searchLectures, usedTime: $viewModel.usedTime)
                    .zIndex(1)
                
                
                // 시간표 시각화
                EditableTimetableView(
                    lectures: $viewModel.customTimetable,
                    canEdit: $canEdit,
                    isAlertPresented: $isDeleteAlertPresented
                )
                .padding(.horizontal, -10)
            }
            .padding(.horizontal, 20)
        }
        .onChange(of: searchText) { newValue in
            debounceCancellable?.cancel()
            debounceCancellable = Just(newValue)
                .delay(for: .milliseconds(500), scheduler: RunLoop.main)
                .sink { debouncedValue in
                    searchTextDebounced = debouncedValue
                    if !debouncedValue.trimmingCharacters(in: .whitespaces).isEmpty {
                        viewModel.searchLectures(keyword: debouncedValue)
                    }
                }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // 시간표 저장
                    let year = viewModel.currentYearSemester.year
                    let semester = viewModel.currentYearSemester.semester
                    viewModel.saveTimetable(year: year, semester: semester, timeTableName: "기본", isRepresent: isMainTimetableSet, selectedLectureIds: viewModel.customTimetable.map{ $0.id }) {
//                        isPresented = false
                        showAlert = true
                        alertMessage = "저장되었습니다."
                    }
                }, label: {
                    Text("저장")
                })
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("확인", role: .cancel) {
                isPresented = false
            }
        }
    }
}

//#Preview {
//    CustomCreateTimetableView(viewModel: TimetableViewModel(), isPresented: .constant(true))
//}
