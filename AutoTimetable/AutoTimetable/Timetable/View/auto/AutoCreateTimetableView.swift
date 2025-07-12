//
//  AutoCreateTimetableView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/24/25.
//

import SwiftUI
import Combine

// 선택된 전공, 강의는 뷰모델에 저장
struct AutoCreateTimetableView: View {
    
    @StateObject var viewModel = GenerateTimetableViewModel()
    @Binding var isPresented: Bool

    // 전공 검색 텍스트
    @State private var searchText = ""
    // 강의 검색 텍스트
    @State private var searchLectureText = ""
    @State private var searchLectureTextDebounced: String = ""
    @State private var debounceCancellable: AnyCancellable? = nil
    
    @State private var isActive = false
    
    @FocusState private var isFocused: FocusField?
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text("포함시킬 전공")
                        .font(.title)
                    // 전공 검색 바
                    DepartmentSearchBar(allDepartments: $viewModel.allDepartments, selectedDepartments: $viewModel.selectedDepartments, searchText: $searchText)
                        .zIndex(1)
                    
                    // 전공 과목 수 선택
                    HStack {
                        Text("전공 과목 수:")
                        Spacer()
                        Picker("전공 과목 수", selection: $viewModel.targetMajorCnt) {
                            ForEach(0..<11, id: \.self) { count in
                                Text("\(count)개").tag(count)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    // 교양 과목 수 선택
                    HStack {
                        Text("교양 과목 수:")
                        Spacer()
                        Picker("교양 과목 수", selection: $viewModel.targetCultureCnt) {
                            ForEach(0..<4, id: \.self) { count in
                                Text("\(count)개").tag(count)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Divider()
                    
                    Text("제외하고 싶은 강의")
                        .font(.title)
                    // 제외할 강의 추가, 삭제
                    LectureSearchBar(searchText: $searchLectureText, selectedLectures: $viewModel.selectedDislikeLectures, searchedLectures: $viewModel.searchLectures)
                        .zIndex(1)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            } // scrollView
            
            NavigationLink(destination: SelectLikeLecturesView(viewModel: viewModel, isPresented: $isPresented), isActive: $isActive, label: {
                Text("다음")
                    .modifier(MyButtonModifier(isDisabled: false))
                    .padding(.horizontal, 20)
            })
        } // vstack
        .onAppear {
            let year = viewModel.currentYearSemester.year
            let semester = viewModel.currentYearSemester.semester
            viewModel.getAllDepartments(year: year, semester: semester)
        }
        .onChange(of: searchLectureText) { newValue in
            debounceCancellable?.cancel()
            debounceCancellable = Just(newValue)
                .delay(for: .milliseconds(500), scheduler: RunLoop.main)
                .sink { debouncedValue in
                    searchLectureTextDebounced = debouncedValue
                    viewModel.searchLectures(keyword: debouncedValue)
                }
        }
    }
    
    enum FocusField: Hashable {
        case department
        case excludeLecture
    }
    
}

//#Preview {
//    AutoCreateTimetableView(viewModel: TimetableViewModel(), isPresented: .constant(true))
//}
