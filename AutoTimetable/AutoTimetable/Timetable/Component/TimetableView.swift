//
//  TimetableView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/5/25.
//

import SwiftUI

// MARK: - 공통 상수 정의
struct TimetableConstants {
    // [수정] "토" 요일을 배열에 추가합니다. 이제 6일이 기준이 됩니다.
    static let days = ["월", "화", "수", "목", "금", "토", "일"]
    static let defaultStartHour = 9
    static let defaultEndHour = 18
    static let allHours = Array(0..<24)
    static let cornerCellWidth: CGFloat = 25
    static let cornerCellHeight: CGFloat = 20
    static let cellHeight: CGFloat = 50
    
    static let lectureColors: [Color] = [
        Color(red: 0.95, green: 0.6, blue: 0.6),
        Color(red: 0.6, green: 0.8, blue: 0.6),
        Color(red: 0.6, green: 0.6, blue: 0.95),
        Color(red: 0.95, green: 0.75, blue: 0.5),
        Color(red: 0.8, green: 0.6, blue: 0.8),
        Color(red: 0.95, green: 0.9, blue: 0.6),
        Color(red: 0.5, green: 0.8, blue: 0.8),
        Color(red: 0.8, green: 0.7, blue: 0.9),
        Color(red: 0.7, green: 0.9, blue: 0.7),
        Color(red: 0.9, green: 0.7, blue: 0.7),
        Color(red: 0.7, green: 0.7, blue: 0.9),
        Color(red: 0.9, green: 0.8, blue: 0.6)
    ]
}


// MARK: - 베이스 시간표 뷰
struct BaseTimetableView<Content: View>: View {
    let lectures: [Lecture]
    let showFullDay: Bool
    let content: (CGFloat, GeometryProxy) -> Content
    
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
                VStack(spacing: 2) {
                    Text(lecture.name).font(.caption2).lineLimit(1).minimumScaleFactor(0.5)
                    Text(lecture.professor).font(.caption2).lineLimit(1).minimumScaleFactor(0.5)
                }
                .padding(2)
                .frame(width: cellWidth - 4, height: height - 4)
                .background(lectureColor.opacity(0.7))
                .cornerRadius(4)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(lectureColor.opacity(0.9), lineWidth: 1))
                .position(x: x, y: y)
            )
            
            views.append(block)
        }
        
        return views
    }
}


// MARK: - 나머지 뷰들 (변경 없음)
struct TimetableView: View {
    let lectures: [Lecture]
    var body: some View { BaseTimetableView(lectures: lectures, showFullDay: false) { _, _ in EmptyView() } }
}

struct EditableTimetableView: View {
    @Binding var lectures: [Lecture]
    @Binding var canEdit: Bool
    @Binding var isAlertPresented: Bool
    
    @State private var selectedLecture: Lecture? = nil
    @State private var showInfoModal = false
    
    var body: some View {
        BaseTimetableView(lectures: lectures, showFullDay: false) { cellWidth, geo in EmptyView() }
        .onTapGesture { location in
            if let lectureToHandle = lectures.first {
                self.selectedLecture = lectureToHandle
                if canEdit { self.isAlertPresented = true } else { self.showInfoModal = true }
            }
        }
        .sheet(isPresented: $showInfoModal) { if let selectedLecture { LectureInfoModal(lecture: selectedLecture) } }
        .alert("정말 삭제할까요?", isPresented: $isAlertPresented) {
            Button("삭제", role: .destructive) { if let selectedLecture { lectures.removeAll { $0.id == selectedLecture.id } } }
            Button("취소", role: .cancel) { }
        }
    }
}

struct TimeExclusionView: View {
    @Binding var excludedTimes: Set<TimeSlot>
    @ObservedObject var timetableViewModel: GenerateTimetableViewModel

    var body: some View {
        BaseTimetableView(lectures: timetableViewModel.selectedLikeLectures, showFullDay: true) { cellWidth, geo in
            ZStack {
                // 전체 셀 오프셋
                ForEach(TimetableConstants.allHours, id: \.self) { hour in
                    ForEach(0..<TimetableConstants.days.count, id: \.self) { dayIndex in
                        let key = TimeSlot(dayIndex: dayIndex, hour: hour)

                        Rectangle()
                            .fill(excludedTimes.contains(key) ? Color.red.opacity(0.3) : Color.clear)
                            .frame(width: cellWidth, height: TimetableConstants.cellHeight)
                            .contentShape(Rectangle())
                            .onTapGesture { toggleTimeSlot(key) }
                            .position(
                                x: CGFloat(dayIndex) * cellWidth + cellWidth / 2 + TimetableConstants.cornerCellWidth,
                                y: CGFloat(hour) * TimetableConstants.cellHeight + TimetableConstants.cellHeight / 2 + TimetableConstants.cornerCellHeight
                            )
                    }
                }
            }
        }
    }

    private func toggleTimeSlot(_ key: TimeSlot) {
        if excludedTimes.contains(key) {
            excludedTimes.remove(key)
            timetableViewModel.emptyUsedTime(timeString: key.toTimeString())
        } else {
            excludedTimes.insert(key)
            timetableViewModel.fillUsedTime(timeString: key.toTimeString())
        }
    }
}




struct LectureInfoModal: View {
    @Environment(\.dismiss) var dismiss
    var lecture: Lecture
    
    var body: some View {
        VStack {
            Text("\(lecture.name)")
            Text("\(lecture.professor)")
            Text("\(lecture.codeSection)")
            Text("\(lecture.credit)")
            Text("\(lecture.notice)")
        }
        .padding()
    }
}


//struct TimetableViewDto: View {
//
//    let days = ["월", "화", "수", "목", "금", "토", "일"]
//    let hours = Array(0..<24)
//
//    let conerCellWidth: CGFloat = 20
//    let conerCellHeight: CGFloat = 20
//
//    let cellHeight: CGFloat = 50
//
//    let lectures: [ExternalLecture]
//
//
//
//
//
//    var body: some View {
//
//        //        ScrollView {
//
//        VStack(spacing: 0) {
//
//            GeometryReader { geo in
//
//                let cellWidth = (geo.size.width - conerCellWidth) / CGFloat(self.days.count)
//
//                // 🟦 기본 시간표 그리드
//                VStack(spacing: 0) {
//                    // 요일 헤더
//                    HStack(spacing: 0) {
//                        Text(" ")
//                            .frame(width: conerCellWidth, height: conerCellHeight)
//
//                        ForEach(days, id: \.self) { day in
//                            Text(day)
//                                .frame(width: cellWidth, height: conerCellHeight)
//                                .font(.caption)
//                        }
//                    }
//
//                    // 시간 + 셀
//                    ForEach(hours, id: \.self) { hour in
//                        HStack(spacing: 0) {
//                            Text(String(format: "%2d", hour))
//                                .frame(width: conerCellWidth, height: cellHeight, alignment: .topTrailing)
//                                .font(.caption)
//
//                            ForEach(0..<days.count, id: \.self) { _ in
//                                Rectangle()
//                                    .fill(Color.white)
//                                    .frame(width: cellWidth, height: cellHeight)
//                                    .border(Color.gray.opacity(0.3))
//                            }
//                        }
//                    }
//
//                }
//
//                // 🟨 강의 블록
//                ForEach(lectures, id: \.self) { lecture in
//                    let blocks = createLectureBlock(lecture: lecture, cellWidth: cellWidth)
//
//
//                    ForEach(blocks.indices, id: \.self) { index in
//                        blocks[index]
//                    }
//                }
//
//            }
//            .frame(height: CGFloat(hours.count) * cellHeight + conerCellHeight)
//        }
//        //        }
//    }
//
//    //    "월900-1015,수1030-1145"
//    func createLectureBlock(lecture: ExternalLecture, cellWidth: CGFloat) -> [AnyView] {
//        let dayMap = ["월": 0, "화": 1, "수": 2, "목": 3, "금": 4, "토": 5, "일": 6]
//        let times = lecture.time.components(separatedBy: ",")
//        var views: [AnyView] = []
//
//        for time in times {
//            guard let xIndex = dayMap[String(time.prefix(1))] else { continue }
//            let timeRange = time.dropFirst()
//            let parts = timeRange.split(separator: "-")
//            guard parts.count == 2,
//                  let startInt = Int(parts[0]),
//                  let endInt = Int(parts[1]) else { continue }
//
//            let startY = (startInt / 100) * 60 + (startInt % 100)
//            let endY = (endInt / 100) * 60 + (endInt % 100)
//
//            let height = CGFloat(endY - startY) / 60 * cellHeight
//
//            let x = CGFloat(xIndex) * cellWidth + conerCellWidth + cellWidth / 2
//            let y = CGFloat(startY) / 60 * cellHeight + conerCellHeight + height / 2
//
//            let block = AnyView(
//                VStack(spacing: 2) {
//                    Text(lecture.name)
//                        .font(.caption2)
//                        .lineLimit(1)
//                    Text(lecture.professor)
//                        .font(.caption2)
//                        .lineLimit(1)
//                }
//                    .frame(width: cellWidth, height: height)
//                    .background(Color.green.opacity(0.7))
//                    .cornerRadius(4)
//                    .position(x: x, y: y)
//            )
//
//            views.append(block)
//        }
//
//        return views
//    }
//}



// MARK: - DTO를 사용하는 시간표 뷰 (최종 수정 버전)
struct TimetableViewDto: View {

    let lectures: [ExternalLecture]
    // 뷰를 생성할 때 동적 범위를 보여줄지(false), 전체를 보여줄지(true) 결정합니다.
    let showFullDay = false

    // 표시할 시간 범위를 계산하는 로직
    private var displayHours: [Int] {
        if showFullDay {
            return TimetableConstants.allHours
        } else {
            if lectures.isEmpty {
                return Array(TimetableConstants.defaultStartHour...TimetableConstants.defaultEndHour)
            }
            // calculateDynamicTimeRange 함수를 호출하여 시간 범위를 계산합니다.
            let (startHour, endHour) = calculateDynamicTimeRange()
            return Array(startHour...endHour)
        }
    }
    
    // ExternalLecture에 맞춰 동적 시간 범위를 계산하는 함수 (새로 추가)
    private func calculateDynamicTimeRange() -> (startHour: Int, endHour: Int) {
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
                // 강의가 12:00에 끝나면 마지막 시간은 11시 교시이므로, 정각에 끝나는 경우 -1을 해줍니다.
                let lectureEndHour = (endInt % 100 > 0) ? (endInt / 100) : (endInt / 100 - 1)
                
                minHour = min(minHour, lectureStartHour)
                maxHour = max(maxHour, lectureEndHour)
            }
        }
        
        return (minHour, maxHour)
    }

    var body: some View {
        GeometryReader { geo in
            let cellWidth = (geo.size.width - TimetableConstants.cornerCellWidth) / CGFloat(TimetableConstants.days.count)
            
            ZStack {
                // ... (그리드 및 강의 블록을 그리는 나머지 body 코드는 이전과 동일) ...
                // 🟦 기본 시간표 그리드
                VStack(spacing: 0) {
                    // 요일 헤더
                    HStack(spacing: 0) {
                        Text(" ")
                            .frame(width: TimetableConstants.cornerCellWidth, height: TimetableConstants.cornerCellHeight)

                        ForEach(TimetableConstants.days, id: \.self) { day in
                            Text(day)
                                .frame(width: cellWidth, height: TimetableConstants.cornerCellHeight)
                                .font(.caption)
                        }
                    }

                    // 시간 + 셀
                    ForEach(displayHours, id: \.self) { hour in
                        HStack(spacing: 0) {
                            Text(String(format: "%2d", hour))
                                .frame(width: TimetableConstants.cornerCellWidth, height: TimetableConstants.cellHeight, alignment: .topTrailing)
                                .font(.caption)
                                .padding(.trailing, 2)

                            ForEach(0..<TimetableConstants.days.count, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color(UIColor.systemBackground))
                                    .frame(width: cellWidth, height: TimetableConstants.cellHeight)
                                    .border(Color.gray.opacity(0.3), width: 0.5)
                            }
                        }
                    }
                }
                
                // 🟨 강의 블록
                ForEach(lectures, id: \.self) { lecture in
                    let blocks = createLectureBlock(lecture: lecture, cellWidth: cellWidth, viewStartHour: displayHours.first ?? 0)

                    ForEach(blocks.indices, id: \.self) { index in
                        blocks[index]
                    }
                }
            }
        }
        .frame(height: CGFloat(displayHours.count) * TimetableConstants.cellHeight + TimetableConstants.cornerCellHeight)
    }
    
    // createLectureBlock 함수는 이전 답변과 동일
    func createLectureBlock(lecture: ExternalLecture, cellWidth: CGFloat, viewStartHour: Int) -> [AnyView] {
        let times = lecture.time.components(separatedBy: ",")
        var views: [AnyView] = []
        
        let colorIndex = abs(lecture.name.hashValue) % TimetableConstants.lectureColors.count
        let lectureColor = TimetableConstants.lectureColors[colorIndex]

        for time in times {
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
                VStack(spacing: 2) {
                    Text(lecture.name)
                        .font(.caption2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text(lecture.professor)
                        .font(.caption2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .padding(2)
                .frame(width: cellWidth - 4, height: height - 4)
                .background(lectureColor.opacity(0.7))
                .cornerRadius(4)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(lectureColor.opacity(0.9), lineWidth: 1))
                .position(x: x, y: y)
            )

            views.append(block)
        }

        return views
    }
}
