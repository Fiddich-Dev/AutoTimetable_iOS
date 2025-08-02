//
//  TimetableView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/5/25.
//

import SwiftUI


// 편집이 가능한 시간표 뷰(강의삭제, 강의추가, 강의정보 보기)
// 편집이 불가능한 시간표 뷰(에타 조회)
// 제외하고 싶은 부분을 선택하는 시간표 뷰(풀 사이즈)





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
                VStack(spacing: 2) {
                    Text(lecture.name).font(.caption2).lineLimit(1).minimumScaleFactor(0.5)
                    Text(lecture.professor).font(.caption2).lineLimit(1).minimumScaleFactor(0.5)
                }
                .padding(2)
                .frame(width: cellWidth - 4, height: height - 4)
                .background(lectureColor.opacity(0.7))
                .cornerRadius(4)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(lectureColor.opacity(0.9), lineWidth: 1))
                .contentShape(Rectangle()) // ⭐️ 제스처 인식 영역 명시
                .onTapGesture {
                    print("강의 탭: \(lecture.name)")
                    selectedLecture = lecture
                    showInfoModal = true
                }
                .sheet(isPresented: $showInfoModal) { if let selectedLecture { LectureInfoModal(lecture: selectedLecture)
                        .presentationDetents([.medium])
                } }
                .position(x: x, y: y)
            )
            views.append(block)
        }
        
        return views
    }
}


// MARK: - 기본 읽기 전용 시간표
struct TimetableView: View {
    
    let lectures: [Lecture]
    var body: some View { BaseTimetableView(lectures: lectures, showFullDay: false) { _, _ in EmptyView() } }
}

// MARK: - 읽기 쓰기 모두 가능한 시간표
struct EditableTimetableView: View {
    @Binding var lectures: [Lecture]
    @Binding var canEdit: Bool
    
    @State var isAlertPresented: Bool = false
    @State private var selectedLecture: Lecture? = nil
    @State private var showInfoModal = false
    
    var body: some View {
        BaseTimetableView(lectures: lectures, showFullDay: false) { cellWidth, geo in EmptyView() }
//        .onTapGesture { location in
//            if let lectureToHandle = lectures.first {
//                self.selectedLecture = lectureToHandle
//                if canEdit { self.isAlertPresented = true }
//                else { self.showInfoModal = true }
//            }
//        }
//        .sheet(isPresented: $showInfoModal) { if let selectedLecture { LectureInfoModal(lecture: selectedLecture) } }
//        .alert("정말 삭제할까요?", isPresented: $isAlertPresented) {
//            Button("삭제", role: .destructive) { if let selectedLecture { lectures.removeAll { $0.id == selectedLecture.id } } }
//            Button("취소", role: .cancel) { }
//        }
    }
}

// MARK: - 제외할 시간을 체크하기
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

// MARK: - 강의 정보 자세히 보기
struct LectureInfoModal: View {
    @Environment(\.dismiss) var dismiss
    var lecture: Lecture
    
    var body: some View {
        VStack(spacing: 16) {
            // 제목
            Text(lecture.name)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(title: "교수님", value: lecture.professor)
                InfoRow(title: "코드", value: lecture.codeSection)
                InfoRow(title: "학점", value: "\(lecture.credit)")
                InfoRow(title: "비고", value: lecture.notice.isEmpty ? "없음" : lecture.notice)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button(action: {
                dismiss()
            }) {
                Text("닫기")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(radius: 10)
        )
        .padding()
    }
}

struct InfoRow: View {
    var title: String
    var value: String

    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

