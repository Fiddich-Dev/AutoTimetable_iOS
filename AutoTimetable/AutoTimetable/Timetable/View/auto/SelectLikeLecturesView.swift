//
//  SelectLikeLecturesView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/25/25.
//

import SwiftUI
import Combine

struct SelectLikeLecturesView: View {
    
    @ObservedObject var viewModel: GenerateTimetableViewModel
    @Binding var isPresented: Bool
    
    @State private var searchLectureText = ""
    @State private var searchLectureTextDebounced: String = ""
    @State private var debounceCancellable: AnyCancellable? = nil
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                Text("듣고 싶은 강의")
                    .font(.title)
                // 포함할 강의 추가, 삭제 바
                LectureSearchBarWithUsedtime(searchText: $searchLectureText, selectedLectures: $viewModel.selectedLikeLectures, searchedLectures: $viewModel.searchLectures, usedTime: $viewModel.usedTime)
                .zIndex(1)
                
                // 편집 안되는 시간표 UI
                TimetableView(lectures: viewModel.selectedLikeLectures)
            }
            .padding(.horizontal, 20)
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SelectExcludeTimeView(viewModel: viewModel, isPresented: $isPresented), label: {
                    Text("다음")
                })
            }
        }
    }
    
}

//#Preview {
//    SelectLikeLecturesView(viewModel: TimetableViewModel(), isPresented: .constant(true))
//}
