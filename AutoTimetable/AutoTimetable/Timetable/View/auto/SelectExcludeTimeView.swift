//
//  SelectExclueTimeView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/25/25.
//

import SwiftUI



struct SelectExcludeTimeView: View {
    
    @ObservedObject var viewModel: GenerateTimetableViewModel
    @Binding var isPresented: Bool

    @State private var excludedTimes: Set<TimeSlot> = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                Text("제외하고 싶은 시간")
                    .font(.title)
                // 제외할 시간대 1시간 단위로 선택
                TimeExclusionView(
                    excludedTimes: $excludedTimes,
                    timetableViewModel: viewModel
                )
                .padding(.horizontal, -10)
            }
            .padding(.horizontal, 20)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: MakedTimetableView(viewModel: viewModel, isPresented: $isPresented)) {
                    Text("완료")
                }
                .simultaneousGesture(TapGesture().onEnded {
                    
                    var generateTimetableOption = GenerateTimetableOption(year: viewModel.currentYear,
                                                                          semester: viewModel.currentSemester,
                                                                          targetMajorCnt: viewModel.targetMajorCnt,
                                                                          targetCultureCnt: viewModel.targetCultureCnt,
                                                                          likeOfficialLectureCodeSection: viewModel.selectedLikeLectures.map { $0.codeSection },
                                                                          dislikeOfficialLectureCodeSection: viewModel.selectedDislikeLectures.map { $0.codeSection },
                                                                          categoryIds: viewModel.selectedCategories.map { $0.id },
                                                                          usedTime: viewModel.usedTime,
                                                                          minCredit: viewModel.minCredit,
                                                                          maxCredit: viewModel.maxCredit,
                                                                          preferMorning: viewModel.preferAfternoon,
                                                                          preferAfternoon: viewModel.preferAfternoon
                    )
                    
                    // 시간표 생성 알고리즘
                    viewModel.generateTimetable(generateTimetableOption: generateTimetableOption)
                })
            }
        }
    }
}



//#Preview {
//    SelectExcludeTimeView(viewModel: TimetableViewModel(), isPresented: .constant(true))
//}
