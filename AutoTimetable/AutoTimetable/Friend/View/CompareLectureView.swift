//
//  CompareView.swift
//  AutoTimetable
//
//  Created by 황인성 on 7/10/25.
//

import SwiftUI
import PopupView


struct FriendSelectorView: View {
    
    @ObservedObject var friendViewModel: FriendViewModel
    
    var body: some View {
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
                NavigationLink(destination: TimetableView_Temp1(compareTimetableDtos: friendViewModel.compareTimetableDtos)) {
                    Text("완료")
                }.simultaneousGesture(TapGesture().onEnded {
                    friendViewModel.compareLectureWithFriend(
                        year: friendViewModel.currentYear,
                        semeser: friendViewModel.currentSemester,
                        memberIds: friendViewModel.selectedFriends.map { $0.id }
                    )
                })
            }
        }
    }
}

struct MultipleSelectionRow: View {
    let friend: Friend
    let isSelected: Bool
    let toggleSelection: () -> Void
    
    var body: some View {
        Button(action: toggleSelection) {
            HStack {
                VStack(alignment: .leading) {
                    Text(friend.username)
                        .font(.body)
                    Text(friend.studentId)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct TimetableView_Temp1: View {
    let compareTimetableDtos: [CompareTimetableDto]
    var body: some View {
        ScrollView {
            BaseTimetableView1(compareTimetableDtos: compareTimetableDtos, showFullDay: false) { _, _ in EmptyView() }
        }
    }
}

struct FriendCompareTimetableView: View {
    @ObservedObject var friendViewModel: FriendViewModel
    
    @State private var selectedLecture: CompareTimetableDto? = nil
    @State private var showAlert = false
    
    private var lectures: [Lecture] {
        friendViewModel.compareTimetableDtos.map { $0.lecture }
    }
    
    var body: some View {
        ScrollView {
            GeometryReader { geo in
                let cellWidth = (geo.size.width - TimetableConstants.cornerCellWidth) / CGFloat(TimetableConstants.days.count)
                
                ZStack {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Text(" ")
                                .frame(width: TimetableConstants.cornerCellWidth, height: TimetableConstants.cornerCellHeight)
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
                                ForEach(0..<TimetableConstants.days.count, id: \.self) { _ in
                                    Rectangle()
                                        .fill(Color(UIColor.systemBackground))
                                        .frame(width: cellWidth, height: TimetableConstants.cellHeight)
                                        .border(Color.gray.opacity(0.3), width: 0.5)
                                }
                            }
                        }
                    }
                    
                    ForEach(friendViewModel.compareTimetableDtos, id: \.lecture.id) { compareDto in
                        let blocks = createLectureBlock(lecture: compareDto.lecture, cellWidth: cellWidth, viewStartHour: displayHours.first ?? 9)
                        ForEach(blocks.indices, id: \.self) { index in
                            blocks[index]
                                .onTapGesture {
                                    selectedLecture = compareDto
                                    showAlert = true
                                }
                        }
                    }
                }
                .alert(isPresented: $showAlert) {
                    if let lecture = selectedLecture {
                        let friendList = lecture.usernames.isEmpty
                        ? "겹치는 친구가 없습니다."
                        : lecture.usernames.enumerated()
                            .map { "\($0.element) (\(lecture.studentIds[$0.offset]))" }
                            .joined(separator: "\n")
                        
                        return Alert(
                            title: Text("겹치는 친구 목록"),
                            message: Text(friendList),
                            dismissButton: .default(Text("닫기"))
                        )
                    } else {
                        return Alert(title: Text("알림"), message: Text("정보가 없습니다."), dismissButton: .default(Text("닫기")))
                    }
                }
                .onAppear {
                    friendViewModel.compareLectureWithFriend(
                        year: friendViewModel.currentYear,
                        semeser: friendViewModel.currentSemester,
                        memberIds: friendViewModel.selectedFriends.map { $0.id }
                    )
                }
            }
            .frame(height: CGFloat(displayHours.count) * TimetableConstants.cellHeight + TimetableConstants.cornerCellHeight)
        }
    }
    
    private var displayHours: [Int] {
        if lectures.isEmpty {
            return Array(TimetableConstants.defaultStartHour...TimetableConstants.defaultEndHour)
        }
        let (start, end) = calculateTimeRange()
        return Array(start...end)
    }
    
    private func calculateTimeRange() -> (Int, Int) {
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
    
    func createLectureBlock(lecture: Lecture, cellWidth: CGFloat, viewStartHour: Int) -> [AnyView] {
        let times = lecture.time.components(separatedBy: ",")
        var views: [AnyView] = []
        
        let colorIndex = abs(lecture.id.hashValue) % TimetableConstants.lectureColors.count
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



struct BaseTimetableView1<Content: View>: View {
    let compareTimetableDtos: [CompareTimetableDto]
    let showFullDay: Bool
    let content: (CGFloat, GeometryProxy) -> Content
    
    @State private var selectedLecture: Lecture? = nil
    @State private var showInfoModal: Bool = false
    @State private var selectedNames: [String] = []
    @State private var selectedStudentIds: [String] = []
    
    private var displayHours: [Int] {
        if showFullDay {
            return TimetableConstants.allHours
        } else {
            if compareTimetableDtos.isEmpty {
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
                
                ForEach(compareTimetableDtos, id: \.id) { compareTimetableDto in
                    let blocks = createLectureBlock(compareTimetableDto: compareTimetableDto, cellWidth: cellWidth, viewStartHour: displayHours.first ?? TimetableConstants.defaultStartHour)
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
        
        for lecture in compareTimetableDtos.map{ $0.lecture } {
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
    func createLectureBlock(compareTimetableDto: CompareTimetableDto, cellWidth: CGFloat, viewStartHour: Int) -> [AnyView] {
        // [개선] 하드코딩된 dayMap을 제거합니다.
        // let dayMap = ["월": 0, "화": 1, "수": 2, "목": 3, "금": 4] // 이 줄을 삭제!
        
        var lecture = compareTimetableDto.lecture
        
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
//                    .contentShape(Rectangle()) // ⭐️ 제스처 인식 영역 명시
//                    .onTapGesture {
//                        print("강의 탭: \(lecture.name)")
//                        selectedLecture = lecture
//                        showInfoModal = true
//                        selectedNames = compareTimetableDto.usernames
//                        selectedStudentIds = compareTimetableDto.studentIds
//                    }
                    .position(x: x, y: y)
            )
            views.append(block)
        }
        
        return views
    }
}

struct MembersInfoModal: View {
    
    var memberName: [String]
    var memberStudentId: [String]
    
    var body: some View {
        ForEach(memberName.indices, id: \.self) { index in
            HStack {
                Text("\(memberName[index]) : \(memberStudentId[index])")
            }
            
        }
    }
}


