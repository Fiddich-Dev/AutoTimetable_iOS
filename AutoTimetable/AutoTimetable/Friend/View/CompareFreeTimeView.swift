//
//  CompareFreeTimeView.swift
//  AutoTimetable
//
//  Created by Hwang insung on 8/2/25.
//

import SwiftUI

struct FriendSelectorView2: View {
    
    @ObservedObject var friendViewModel: FriendViewModel
    
    var body: some View {
        ZStack {
            if(friendViewModel.isLoading) {
                ProgressView()
                    .zIndex(1)
            }
            
            List(friendViewModel.myFriends, id: \.id) { friend in
                MultipleSelectionRow(
                    friend: friend,
                    isSelected: friendViewModel.selectedFriends.contains(friend)
                ) {
                    if friendViewModel.selectedFriends.contains(friend) {
                        friendViewModel.selectedFriends.removeAll { $0.id == friend.id }
                    } else {
                        friendViewModel.selectedFriends.append(friend)
                    }
                }
            }
            .navigationTitle("친구 선택")
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: TimetableView_Temp(isLoading: $friendViewModel.isLoading, lectures: friendViewModel.compareTimes)
                        .onAppear {
                            friendViewModel.compareTimeWithFriend(year: friendViewModel.currentYear, semeser: friendViewModel.currentSemester, memberIds: friendViewModel.selectedFriends.map { $0.id })
                        }
                    ) {
                        Text("완료")
                    }
                }
            }
        }
    }
}


struct TimetableView_Temp: View {
    @Binding var isLoading: Bool
    let lectures: [Lecture]
    var body: some View {
        ScrollView {
            BaseTimetableView2(lectures: lectures, showFullDay: false) { _, _ in EmptyView() }
        }
    }
}


struct BaseTimetableView2<Content: View>: View {
    let lectures: [Lecture]
    let showFullDay: Bool
    let content: (CGFloat, GeometryProxy) -> Content
    
    @State private var selectedLecture: Lecture? = nil
    @State private var showInfoModal: Bool = false
    
    private var displayHours: [Int] {
        if showFullDay {
            return TimetableConstants.allHours
        } else {
            if lectures.isEmpty {
                return Array(TimetableConstants.defaultStartHour...TimetableConstants.defaultEndHour)
            }
            let (startHour, endHour) = calculateTimeRange()
            return Array(startHour...endHour)
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            // [자동 개선] days 배열의 count가 6으로 늘었기 때문에 cellWidth가 자동으로 계산됩니다.
            let cellWidth = (geo.size.width - TimetableConstants.cornerCellWidth) / CGFloat(TimetableConstants.days.count)
            
            ZStack {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text(" ")
                            .frame(width: TimetableConstants.cornerCellWidth, height: TimetableConstants.cornerCellHeight)
                        
                        // [자동 개선] days 배열이 "토"까지 포함하므로 헤더가 6열로 그려집니다.
                        ForEach(TimetableConstants.days, id: \.self) { day in
                            Text(day)
                                .frame(width: cellWidth, height: TimetableConstants.cornerCellHeight)
                                .font(.caption)
                        }
                    }
                    
                    ForEach(displayHours, id: \.self) { hour in
                        HStack(spacing: 0) {
                            Text(String(format: "%2d", hour))
                                .frame(width: TimetableConstants.cornerCellWidth, height: TimetableConstants.cellHeight, alignment: .topTrailing)
                                .font(.caption)
                                .padding(.trailing, 2)
                            
                            // [자동 개선] days 배열의 count가 6이므로 그리드 셀이 6열로 그려집니다.
                            ForEach(0..<TimetableConstants.days.count, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color(UIColor.systemBackground))
                                    .frame(width: cellWidth, height: TimetableConstants.cellHeight)
                                    .border(Color.gray.opacity(0.3), width: 0.5)
                            }
                        }
                    }
                }
                
                ForEach(lectures, id: \.id) { lecture in
                    let blocks = createLectureBlock(lecture: lecture, cellWidth: cellWidth, viewStartHour: displayHours.first ?? TimetableConstants.defaultStartHour)
                    ForEach(blocks.indices, id: \.self) { index in
                        blocks[index]

                    }
                }
                
                content(cellWidth, geo)
            }
        }
        .frame(height: CGFloat(displayHours.count) * TimetableConstants.cellHeight + TimetableConstants.cornerCellHeight)
    }
    
    private func calculateTimeRange() -> (startHour: Int, endHour: Int) {
        var minHour = TimetableConstants.defaultStartHour
        var maxHour = TimetableConstants.defaultEndHour
        
        for lecture in lectures {
            let times = lecture.time.components(separatedBy: ",")
            for time in times {
                let timeRange = time.dropFirst()
                let parts = timeRange.split(separator: "-")
                guard parts.count == 2,
                      let startInt = Int(parts[0]),
                      let endInt = Int(parts[1]) else { continue }
                
                let lectureStartHour = startInt / 100
                let lectureEndHour = (endInt % 100 > 0) ? (endInt / 100) : (endInt / 100 - 1)
                
                minHour = min(minHour, lectureStartHour)
                maxHour = max(maxHour, lectureEndHour)
            }
        }
        
        return (minHour, maxHour)
    }
    
    // 이 함수의 로직이 가장 중요하게 바뀝니다.
    func createLectureBlock(lecture: Lecture, cellWidth: CGFloat, viewStartHour: Int) -> [AnyView] {
        // [개선] 하드코딩된 dayMap을 제거합니다.
        // let dayMap = ["월": 0, "화": 1, "수": 2, "목": 3, "금": 4] // 이 줄을 삭제!
        
        let times = lecture.time.components(separatedBy: ",")
        var views: [AnyView] = []
        
        let colorIndex = abs(lecture.id.hashValue) % TimetableConstants.lectureColors.count
        let lectureColor = TimetableConstants.lectureColors[colorIndex]
        
        for time in times {
            // [개선] 요일 문자를 기반으로 TimetableConstants.days 배열에서 직접 인덱스를 찾습니다.
            // "토"가 들어와도 정상적으로 5라는 인덱스를 찾을 수 있습니다.
            guard let dayPrefix = time.first.map(String.init),
                  let xIndex = TimetableConstants.days.firstIndex(of: dayPrefix) else { continue }
            
            let timeRange = time.dropFirst()
            let parts = timeRange.split(separator: "-")
            guard parts.count == 2,
                  let startInt = Int(parts[0]),
                  let endInt = Int(parts[1]) else { continue }
            
            let startHourValue = startInt / 100
            let startMinute = startInt % 100
            let endHourValue = endInt / 100
            let endMinute = endInt % 100
            
            let startTotalMinutes = startHourValue * 60 + startMinute
            let endTotalMinutes = endHourValue * 60 + endMinute
            
            let viewStartMinutes = viewStartHour * 60
            let relativeStartMinutes = startTotalMinutes - viewStartMinutes
            let durationMinutes = endTotalMinutes - startTotalMinutes
            
            let height = CGFloat(durationMinutes) / 60.0 * TimetableConstants.cellHeight
            let x = CGFloat(xIndex) * cellWidth + TimetableConstants.cornerCellWidth + cellWidth / 2
            let y = CGFloat(relativeStartMinutes) / 60.0 * TimetableConstants.cellHeight + TimetableConstants.cornerCellHeight + height / 2
            
            let block = AnyView(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.green.opacity(0.2))
                    .frame(width: cellWidth-2, height: height-2)
                    .position(x: x, y: y)
            )
            views.append(block)
        }
        
        return views
    }
}
