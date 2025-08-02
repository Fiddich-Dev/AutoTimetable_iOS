//
//  CustomCreateTimetableView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/27/25.
//

import SwiftUI
import Combine

struct CustomCreateTimetableView: View {
    
    @StateObject var viewModel: GenerateTimetableViewModel
    
    @Binding var isPresented: Bool
    
    // 메인시간표로 저장할지
    @State private var isMainTimetableSet: Bool = false
    @State var showAlert: Bool = false
    
    init(authViewModel: AuthViewModel, isPresented: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: GenerateTimetableViewModel(viewModel: authViewModel))
        self._isPresented = isPresented
    }
    
    var body: some View {
        ZStack {
            if(viewModel.isLoading) {
                ProgressView()
            }
            
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
                    LectureSearchBarWithUsedtime(viewModel: viewModel, selectedLectures: $viewModel.customTimetableLectures, usedTime: $viewModel.usedTime)
                    
                    // 시간표 시각화
                    EditableTimetableView(
                        lectures: $viewModel.customTimetableLectures,
                        canEdit: .constant(true)
                    )
                    .padding(.horizontal, -10)
                }
                .padding(.horizontal, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.saveTimetable(createdTimetable: CreatedTimetable(year: viewModel.currentYear, semester: viewModel.currentSemester, timeTableName: "custom", isRepresent: isMainTimetableSet, lectures: viewModel.customTimetableLectures)) {
                            showAlert = true
                        }
                    }, label: {
                        Text("저장")
                    })
                }
            }
            .alert("저장되었습니다", isPresented: $showAlert) {
                Button("확인", role: .cancel) {
                    isPresented = false
                }
            }
        }
    }
}

//#Preview {
//    CustomCreateTimetableView(viewModel: TimetableViewModel(), isPresented: .constant(true))
//}
