//
//  TimetableView2.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/12/25.
//

import SwiftUI

//struct Lecture: Identifiable {
//    let id = UUID()
//    let name: String
//    let professor: String
//    let times: String
//}
//
//struct LectureTime {
//    let dayIndex: Int   // 0 = 월, ..., 6 = 일
//    let start: Int      // 시작 시간 (분 단위)
//    let end: Int        // 종료 시간 (분 단위)
//}

// MARK: - 시간 문자열 파싱

//func parseLectureTimes(_ timeString: String) -> [LectureTime] {
//    let dayMap = ["월": 0, "화": 1, "수": 2, "목": 3, "금": 4, "토": 5, "일": 6]
//    let entries = timeString.components(separatedBy: ",")
//    
//    return entries.compactMap { entry in
//        guard entry.count >= 9 else { return nil }
//        
//        let dayStr = String(entry.prefix(1))
//        guard let day = dayMap[dayStr] else { return nil }
//        
//        let timeParts = entry.dropFirst().split(separator: "-")
//        guard timeParts.count == 2 else { return nil }
//        
//        func toMinutes(_ t: Substring) -> Int? {
//            guard t.count == 4,
//                  let hour = Int(t.prefix(2)),
//                  let minute = Int(t.suffix(2)) else { return nil }
//            return hour * 60 + minute
//        }
//        
//        guard let start = toMinutes(timeParts[0]), let end = toMinutes(timeParts[1]) else { return nil }
//        
//        return LectureTime(dayIndex: day, start: start, end: end)
//    }
//}

// MARK: - UI

struct TimetableView2: View {
    
    let days = ["월", "화", "수", "목", "금", "토", "일"]
    let hours = Array(0..<24)
    let cellWidth: CGFloat = 50
    let cellHeight: CGFloat = 50
    
    let s: CGFloat = 20
    let screenWidth = UIScreen.main.bounds.width - 20
    
    @StateObject var timetableViewModel = TimetableViewModel()
    
    // 실제 수업 데이터
    let lectures: [Lecture] = [
        Lecture(
            id: 1, code: "GEDM001", codeSection: "GEDM001-02", name: "고전명저북클럽", professor: "김준태", type: "교양", time: "금1000-1050,금1100-1150", place: "", credit: "3", target: "인문사회", notice: "플립러닝(온라인[사전제작]+오프라인), ※ 수강삭제 및 철회불가 ※", department: "culture"
        ),
        Lecture(
            id: 928, code: "KLC2017", codeSection: "KLC2017-01", name: "동아시아역사고전읽기", professor: "안대희", type: "전공일반", time: "화1500-1615,목1630-1745", place: "", credit: "3", target: "인문사회", notice: "오프라인", department: "classicalChinese"
        )
    ]
    
    var body: some View {
        ScrollView {
            
            Button(action: {
                timetableViewModel.getAllTimetable()
            }, label: {
                Text("시간표 조회")
            })
            
            Button(action: {
                timetableViewModel.generateTimetables()
            }, label: {
                Text("시간표 자동생성")
            })
            
            ZStack {
                // 🟦 기본 시간표 그리드
                VStack(spacing: 0) {
                    // 요일 헤더
                    HStack(spacing: 0) {
                        Text(" ")
                            .frame(width: s, height: s)
                        
                        ForEach(days, id: \.self) { day in
                            Text(day)
                                .frame(width: (screenWidth - s) / CGFloat(days.count), height: s)
                                .font(.caption)
                        }
                    }
                
                    
                    // 시간 + 셀
                    ForEach(hours, id: \.self) { hour in
                        HStack(spacing: 0) {
                            Text(String(format: "%2d", hour))
                                .frame(width: 20, height: cellHeight, alignment: .topTrailing)
                                .font(.caption)
                            
                            ForEach(0..<days.count, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: (screenWidth - s) / CGFloat(days.count), height: cellHeight)
                                    .border(Color.gray.opacity(0.3))
                            }
                        }
                    }
                    
                    
                }
                .padding(.horizontal, 10)
                
                
                ForEach(lectures, id: \.id) { lecture in
                        ForEach(createLectureBlock(lecture: lecture).indices, id: \.self) { index in
                            createLectureBlock(lecture: lecture)[index]
                        }
                    }
                
            }
            
        }
    }
    
    //    "월900-1015,수1030-1145"
    func createLectureBlock(lecture: Lecture) -> [AnyView] {
        let dayMap = ["월": 0, "화": 1, "수": 2, "목": 3, "금": 4, "토": 5, "일": 6]
        let times = lecture.time.components(separatedBy: ",")
        var views: [AnyView] = []
        
        for time in times {
            guard let x = dayMap[String(time.prefix(1))] else { continue }
            
            let timeRange = time.dropFirst()
            let parts = timeRange.split(separator: "-")
            
            guard let startInt = Int(parts[0]), let endInt = Int(parts[1]) else { continue }
            
            let startY = (startInt / 100) * 60 + (startInt % 100)
            let endY = (endInt / 100) * 60 + (endInt % 100)
            
            let width = (screenWidth - s) / CGFloat(days.count)
            let height = CGFloat(endY - startY) / 60 * cellHeight
            
            let block = AnyView(
                VStack {
                    Text(lecture.name)
                    Text(lecture.professor)
                    
                }
                    .frame(width: width, height: height)
                    .background(Color.green)
                    .position(x: 10 + s + CGFloat(x) * width + width / 2, y: s + CGFloat(startY) / 60 * cellHeight + height / 2)
                
            )
            
            views.append(block)
        }
        return views
    }
}

#Preview {
    TimetableView2()
}
