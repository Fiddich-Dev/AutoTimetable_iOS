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
    
    @State private var selectedIndex: Int = 0
    @State var showAlert: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                // 시간표가 있으면
                if(!viewModel.makedTimetablesLectures.isEmpty) {
                    
                    // 현재 시간표 인덱스, 시간표 편집버튼
                    HStack {
                        // 저장된 시간표 개수와 현재위치 표시
                        Text("\(selectedIndex+1) / \(viewModel.makedTimetablesLectures.count)")
                            .padding(.top, 10)
                            .font(.title)
                        
                        Spacer()
                        
                        // 편집 기능은 제외
                        // 저장버튼
                        Button(action: {
                            viewModel.saveTimetable(createdTimetable: CreatedTimetable(year: "2025", semester: "2", timeTableName: "auto", isRepresent: false, lectures: viewModel.makedTimetablesLectures[selectedIndex])) {
                                showAlert = true
                            }
                        }, label: {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 24))
                        })
                        
                        // 삭제버튼
                        Button(action: {
                            viewModel.makedTimetablesLectures.remove(at: selectedIndex)
                        }, label: {
                            Image(systemName: "trash")
                                .font(.system(size: 24))
                        })
                    }
                    .padding(.horizontal, 20)
                    
                    TabView(selection: $selectedIndex) {
                        ForEach(viewModel.makedTimetablesLectures.indices, id: \.self) { index in
                            
                            TimetableView(lectures: viewModel.makedTimetablesLectures[index])
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
        .alert("저장되었습니다", isPresented: $showAlert) {
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
    
    /// 현재 선택된 시간표의 높이를 계산하는 컴퓨터 프로퍼티
    private var currentTimetableHeight: CGFloat {
        guard selectedIndex < viewModel.makedTimetablesLectures.count else {
            let defaultHours = TimetableConstants.defaultEndHour - TimetableConstants.defaultStartHour + 1
            return CGFloat(defaultHours) * TimetableConstants.cellHeight + TimetableConstants.cornerCellHeight
        }
        return calculateHeight(for: viewModel.makedTimetablesLectures[selectedIndex])
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
    
}


//#Preview {
//    MakedTimetableView(viewModel: TimetableViewModel(), isPresented: .constant(true))
//}
