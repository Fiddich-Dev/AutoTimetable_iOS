////
////  TimetableOptionView.swift
////  AutoTimetable
////
////  Created by 황인성 on 7/9/25.
////
//
//import SwiftUI
//
//struct TimetableOptionView: View {
//    @ObservedObject var viewModel: GenerateTimetableViewModel
//    @Binding var isPresented: Bool
//    
//    var body: some View {
//        Form {
//            Section(header: Text("학점 설정")) {
//                Stepper(value: $viewModel.minCredit, in: 0...viewModel.maxCredit) {
//                    Text("최소 학점: \(viewModel.minCredit)")
//                }
//                Stepper(value: $viewModel.maxCredit, in: viewModel.minCredit...30) {
//                    Text("최대 학점: \(viewModel.maxCredit)")
//                }
//            }
//            
//            Section(header: Text("시간 선호")) {
//                Toggle("오전 수업 선호", isOn: $viewModel.preferMorning)
//                Toggle("오후 수업 선호", isOn: $viewModel.preferAfternoon)
//            }
//            
//        }
//        .navigationTitle("시간표 옵션")
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                NavigationLink(destination: MakedTimetableView(viewModel: viewModel, isPresented: $isPresented)) {
//                    Text("완료")
//                }
//                .simultaneousGesture(TapGesture().onEnded {
//                    // 시간표 생성 알고리즘
////                    viewModel.generateTimetable(targetMajorCnt: viewModel.targetMajorCnt, targetCultureCnt: viewModel.targetCultureCnt, likeLectureCode: viewModel.selectedLikeLectures.map { $0.id }, dislikeLectureCode: viewModel.selectedDislikeLectures.map { $0.id }, categoryIds: viewModel.selectedDepartments.map { $0.id }, usedTime: viewModel.usedTime, minCredit: viewModel.minCredit, maxCredit: viewModel.maxCredit, preferMorning: viewModel.preferMorning, preferAfternoon: viewModel.preferAfternoon)
//                })
//            }
//        }
//    }
//}
//
