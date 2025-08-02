//
//  SavedTimetableView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/28/25.
//

import SwiftUI
import Combine

struct SavedTimetableView: View {
    @ObservedObject var timetableViewModel: TimetableViewModel
    @StateObject var generateTimetableViewModel: GenerateTimetableViewModel

    @State private var selectedIndex: Int = 0
    @State private var canEdit = false
    @State private var isAlertPresented = false
    @State private var isDeleteAlert = false
    
    init(authViewModel: AuthViewModel, timetableViewModel: TimetableViewModel) {
        self.timetableViewModel = timetableViewModel
        _generateTimetableViewModel = StateObject(wrappedValue: GenerateTimetableViewModel(viewModel: authViewModel))
    }

    var body: some View {
        if timetableViewModel.timetableAboutYearAndSemester.isEmpty {
            VStack {
                Text("저장된 시간표가 없습니다.")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            }
            .onAppear {
                timetableViewModel.getTimetablesByYearAndSemester(year: timetableViewModel.selectedYear, semester: timetableViewModel.selectedSemester, completion: {})
            }
        } else {
            ScrollView {
                VStack {
                    HStack {
                        Text("\(selectedIndex + 1) / \(timetableViewModel.timetableAboutYearAndSemester.count)")
                            .padding(.top, 10)
                            .font(.title)

                        Spacer()

                        if canEdit {
                            Button("취소") {
                                timetableViewModel.getTimetablesByYearAndSemester(year: timetableViewModel.currentYear, semester: timetableViewModel.currentSemester) {
                                    canEdit = false
                                }
                            }.foregroundStyle(.red)

                            Button("완료") {
                                canEdit = false
                                let currentTimetable = timetableViewModel.timetableAboutYearAndSemester[selectedIndex]
                                timetableViewModel.putTimetableLectures(timetableId: currentTimetable.id, lectures: currentTimetable.lectures) {}
                            }
                        } else {
                            Button("편집") {
                                canEdit = true
                                let lectures = timetableViewModel.timetableAboutYearAndSemester[selectedIndex].lectures
                                timetableViewModel.selectedLectures = lectures
                                let lecturesTime = lectures.map { $0.time }
                                timetableViewModel.fillUsedTimeAboutLecturesTime(lecturesTime: lecturesTime)
                            }

                            Button(action: {
                                let timetableId = timetableViewModel.timetableAboutYearAndSemester[selectedIndex].id
                                timetableViewModel.patchMainTimetable(timetableId: timetableId) {
                                    timetableViewModel.getTimetablesByYearAndSemester(year: timetableViewModel.currentYear, semester: timetableViewModel.currentSemester) {}
                                }
                            }) {
                                Image(systemName: timetableViewModel.timetableAboutYearAndSemester[selectedIndex].isRepresent ? "star.fill" : "star")
                                    .font(.system(size: 24))
                            }

                            Button(action: {
                                isDeleteAlert = true
                            }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    if canEdit {
                        LectureSearchBarWithUsedtime(
                            viewModel: generateTimetableViewModel,
                            selectedLectures: Binding(
                                get: { timetableViewModel.selectedLectures },
                                set: { newLectures in
                                    timetableViewModel.selectedLectures = newLectures
                                    timetableViewModel.timetableAboutYearAndSemester[selectedIndex].lectures = newLectures
                                }
                            ),
                            usedTime: $timetableViewModel.usedTime
                        )
                        .padding(.horizontal, 20)
                    }

                    TabView(selection: $selectedIndex) {
                        ForEach(timetableViewModel.timetableAboutYearAndSemester.indices, id: \ .self) { index in
                            EditableTimetableView(
                                lectures: $timetableViewModel.timetableAboutYearAndSemester[index].lectures,
                                canEdit: $canEdit,
                                isAlertPresented: false
                            )
                            .tag(index)
                        }
                    }
                    .frame(height: calculateHeight(for: timetableViewModel.timetableAboutYearAndSemester[selectedIndex].lectures))
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .animation(.easeInOut(duration: 0.4), value: selectedIndex)
                }
            }
            .alert("정말 삭제할까요?", isPresented: $isDeleteAlert) {
                Button("삭제", role: .destructive) {
                    let timetableId = timetableViewModel.timetableAboutYearAndSemester[selectedIndex].id
                    timetableViewModel.deleteTimetable(timetableId: timetableId) {
                        timetableViewModel.getTimetablesByYearAndSemester(year: timetableViewModel.currentYear, semester: timetableViewModel.currentSemester) {
                            let newCount = timetableViewModel.timetableAboutYearAndSemester.count
                            if selectedIndex >= newCount && newCount > 0 {
                                selectedIndex = newCount - 1
                            }
                        }
                    }
                }
                Button("취소", role: .cancel) {}
            }
            .onAppear {
                timetableViewModel.getTimetablesByYearAndSemester(year: timetableViewModel.selectedYear, semester: timetableViewModel.selectedSemester, completion: {})
            }
            .onChange(of: selectedIndex) {
                if canEdit {
                    timetableViewModel.getTimetablesByYearAndSemester(year: timetableViewModel.selectedYear, semester: timetableViewModel.selectedSemester) {
                        canEdit = false
                    }
                }
            }
        }
    }

    private func calculateHeight(for lectures: [Lecture]) -> CGFloat {
        let cornerHeight: CGFloat = 20
        let cellHeight: CGFloat = 50
        let defaultStartHour = 9
        let defaultEndHour = 18

        if lectures.isEmpty {
            return CGFloat(defaultEndHour - defaultStartHour + 1) * cellHeight + cornerHeight
        }

        var minHour = defaultStartHour
        var maxHour = defaultEndHour

        for lecture in lectures {
            let times = lecture.time.components(separatedBy: ",")
            for time in times {
                let parts = time.dropFirst().split(separator: "-")
                guard parts.count == 2,
                      let startInt = Int(parts[0]),
                      let endInt = Int(parts[1]) else { continue }
                let startHour = startInt / 100
                let endHour = (endInt % 100 > 0) ? (endInt / 100) : (endInt / 100 - 1)
                minHour = min(minHour, startHour)
                maxHour = max(maxHour, endHour)
            }
        }

        return CGFloat(maxHour - minHour + 1) * cellHeight + cornerHeight
    }
}


