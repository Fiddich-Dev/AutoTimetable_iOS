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
    
    @FocusState private var isFocused: FocusField?
    
    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text("포함시킬 전공")
                        .font(.title)
                    // 전공 검색 바
                    CategorySearchBar(allCategories: $viewModel.allCategories, selectedCategories: $viewModel.selectedCategories)
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
                    
                    Stepper(value: $viewModel.minCredit, in: 0...viewModel.maxCredit) {
                        Text("최소 학점: \(viewModel.minCredit)")
                    }
                    Stepper(value: $viewModel.maxCredit, in: viewModel.minCredit...30) {
                        Text("최대 학점: \(viewModel.maxCredit)")
                    }
                    
                    Divider()
                    
                    Toggle("오전 수업 선호", isOn: $viewModel.preferMorning)
                    Toggle("오후 수업 선호", isOn: $viewModel.preferAfternoon)
                    
                    Divider()
                    
                    Text("제외하고 싶은 강의")
                        .font(.title)
                    
                    LectureSearchBarWithoutUsedtime(viewModel: viewModel)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            } // scrollView
            .onAppear {
                viewModel.fetchEverytimeCategories(year: "2025", semester: "2")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SelectLikeLecturesView(viewModel: viewModel, isPresented: $isPresented), label: {
                        Text("다음")
                    })
                    .disabled(viewModel.selectedCategories.isEmpty || (viewModel.targetCultureCnt == 0 && viewModel.targetMajorCnt == 0))
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
