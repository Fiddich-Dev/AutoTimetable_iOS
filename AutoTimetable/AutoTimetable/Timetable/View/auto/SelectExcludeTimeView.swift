//
//  SelectExclueTimeView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/25/25.
//

import SwiftUI

struct TimeSlot: Hashable {
    let dayIndex: Int
    let hour: Int
    
    func toTimeString() -> String {
        let dayMap = ["월", "화", "수", "목", "금", "토", "일"]

        let startMinute = hour * 60
        let endMinute = startMinute + 60

        func formatTime(_ totalMinutes: Int) -> String {
            let h = totalMinutes / 60
            let m = totalMinutes % 60
            return String(format: "%02d%02d", h, m)
        }

        let day = dayMap[dayIndex]
        let startTime = formatTime(startMinute)
        let endTime = formatTime(endMinute)
        
        print("\(day)\(startTime)-\(endTime)")

        return "\(day)\(startTime)-\(endTime)"
    }
}


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
                NavigationLink(destination: TimetableOptionView(viewModel: viewModel, isPresented: $isPresented)) {
                    Text("다음")
                }
            }
        }
    }
}



//#Preview {
//    SelectExcludeTimeView(viewModel: TimetableViewModel(), isPresented: .constant(true))
//}
