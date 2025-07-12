//
//  MakedTimetableView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/26/25.
//

import SwiftUI

// 전공관련도 순서
// 학교가는날이 적은 순
// 중간 공강이 적은순
// 오전 수업 선호
// 오후 수업 선호
// 원하는 학점범위
struct MakedTimetableView: View {
    
    @ObservedObject var viewModel: GenerateTimetableViewModel
    @Binding var isPresented: Bool
    
    @State private var selectedOption: SortingOption = .majorRelevance
    @State private var selectedOptions: Set<SortingOption> = []
    @State private var timePreference: TimePreference = .none
    
    @State private var selectedIndex: Int = 0
    
    @State var showAlert: Bool = false
    @State var alertMessage: String = ""
    
    
    /// 현재 선택된 시간표의 높이를 계산하는 컴퓨터 프로퍼티
    private var currentTimetableHeight: CGFloat {
        guard selectedIndex < viewModel.makedTimetables.count else {
            let defaultHours = TimetableConstants.defaultEndHour - TimetableConstants.defaultStartHour + 1
            return CGFloat(defaultHours) * TimetableConstants.cellHeight + TimetableConstants.cornerCellHeight
        }
        return calculateHeight(for: viewModel.makedTimetables[selectedIndex])
    }

    /// 강의 목록을 기반으로 시간표의 실제 높이를 계산하는 함수
    private func calculateHeight(for lectures: [Lecture]) -> CGFloat {
        // 실제 TimetableConstants 값을 사용해야 합니다. 여기서는 예시 값을 사용합니다.
        let cornerHeight: CGFloat = 20
        let cellHeight: CGFloat = 50
        let defaultStartHour = 9
        let defaultEndHour = 18

        if lectures.isEmpty {
            let defaultHoursCount = defaultEndHour - defaultStartHour + 1
            return CGFloat(defaultHoursCount) * cellHeight + cornerHeight
        }

        var minHour = defaultStartHour
        var maxHour = defaultEndHour
        
        for lecture in lectures {
            let times = lecture.time.components(separatedBy: ",")
            for time in times {
                let timeRange = time.dropFirst()
                let parts = timeRange.split(separator: "-")
                guard parts.count == 2, let startInt = Int(parts[0]), let endInt = Int(parts[1]) else { continue }
                let lectureStartHour = startInt / 100
                let lectureEndHour = (endInt % 100 > 0) ? (endInt / 100) : (endInt / 100 - 1)
                minHour = min(minHour, lectureStartHour)
                maxHour = max(maxHour, lectureEndHour)
            }
        }
        
        let displayHoursCount = maxHour - minHour + 1
        return CGFloat(displayHoursCount) * cellHeight + cornerHeight
    }
    
    var body: some View {
        
        ScrollView {
            VStack {
                // 시간표가 있으면
                if(!viewModel.makedTimetables.isEmpty) {
                    
                    // 현재 시간표 인덱스, 시간표 편집버튼
                    HStack {
                        // 저장된 시간표 개수와 현재위치 표시
                        Text("\(selectedIndex+1) / \(viewModel.makedTimetables.count)")
                            .padding(.top, 10)
                            .font(.title)
                        
                        Spacer()
                        
                        // 편집 기능은 제외
                        // 저장버튼
                        Button(action: {
                            let year = viewModel.currentYearSemester.year
                            let semester = viewModel.currentYearSemester.semester
                            // 메인으로 저장할지 정해야함
                            viewModel.saveTimetable(year: year, semester: semester, timeTableName: "기본", isRepresent: false, selectedLectureIds: viewModel.makedTimetables[selectedIndex].map{ $0.id }) {
                                showAlert = true
                                alertMessage = "저장되었습니다."
                                viewModel.makedTimetables.remove(at: selectedIndex)
                            }
                        }, label: {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 24))
                        })
                        
                        // 삭제버튼
                        Button(action: {
                            viewModel.makedTimetables.remove(at: selectedIndex)
                        }, label: {
                            Image(systemName: "trash")
                                .font(.system(size: 24))
                        })
                    }
                    .padding(.horizontal, 20)
                    
                    TabView(selection: $selectedIndex) {
                        ForEach(viewModel.makedTimetables.indices, id: \.self) { index in
                            
                            TimetableView(lectures: viewModel.makedTimetables[index])
                                .tag(index)
                        }
                    }
                    .frame(height: currentTimetableHeight) // 동적 높이 적용
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .animation(.easeInOut(duration: 0.4), value: currentTimetableHeight) // 높이 변경 애니메이션
                }
                else {
                    Text("만들 수 있는 시간표가 없습니다")
                }
            }
            .padding(.horizontal, 10)
        }
        .alert(alertMessage, isPresented: $showAlert) {
                                Button("확인", role: .cancel) { }
                            }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isPresented = false
                }, label: {
                    Image(systemName: "xmark")
                })
            }
        }
    }
    
}

struct SortingOptionSelector: View {
    @Binding var selectedOptions: Set<SortingOption>
    @Binding var timePreference: TimePreference
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: ✅ 다중 선택 옵션 (가로 스크롤)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    
                    // MARK: ✅ 오전/오후 Picker
                    Picker("시간대 선호", selection: $timePreference) {
                        ForEach(TimePreference.allCases) { pref in
                            Text(pref.rawValue).tag(pref)
                        }
                    }
                    
                    ForEach(SortingOption.allCases, id: \.self) { option in
                        Button(action: {
                            if selectedOptions.contains(option) {
                                selectedOptions.remove(option)
                            } else {
                                selectedOptions.insert(option)
                            }
                        }) {
                            Text(option.rawValue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(selectedOptions.contains(option) ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedOptions.contains(option) ? .white : .black)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
        }
    }
}

enum SortingOption: String, CaseIterable, Hashable {
    case majorRelevance = "전공 관련도"
    case fewerSchoolDays = "학교 가는 날 적게"
    case fewerGaps = "공강 적게"
}

enum TimePreference: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case none = "선호 없음"
    case morning = "오전 수업 선호"
    case afternoon = "오후 수업 선호"
}


//#Preview {
//    MakedTimetableView(viewModel: TimetableViewModel(), isPresented: .constant(true))
//}
