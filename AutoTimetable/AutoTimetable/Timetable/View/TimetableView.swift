////
////  TimetableView.swift
////  AutoTimetable
////
////  Created by 황인성 on 6/5/25.
////
//
//import SwiftUI
//
//struct TimetableView: View {
//    
//    // MARK: - Constants
//    private let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
//    private let hoursOfDay = Array(8...21).map { hour in
//        let period = hour < 12 ? "am" : "pm"
//        let hourIn12 = hour > 12 ? hour - 12 : hour
//        return "\(hourIn12)\(period)"
//    }
//    
//    // MARK: - Main View
//    var body: some View {
//        VStack {
//            
//            Text("시간표 자동생성 버튼")
//            
//            HStack(spacing: 0) {
//                TimeLabelColumn(hours: hoursOfDay)
//                    .background(Color.green)
//                    
//                TimetableGrid(days: daysOfWeek, hours: hoursOfDay)
////                    .background(Color.blue)
//            }
//            .padding(.horizontal, 20)
//        }
//    }
//}
//
//// MARK: - Subviews
//
///// 시간 라벨을 표시하는 열
//private struct TimeLabelColumn: View {
//    let hours: [String]
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            
//            // 빈 공간 (요일 라벨 위에)
//            Text("")
//                .font(Font.custom("Pretendard", size: 10))
//                .opacity(0.6)
//                .frame(width: 32, height: 40)
//            
//            // 시간 라벨들
//            ForEach(hours, id: \.self) { hour in
//                Text(hour)
//                    .font(Font.custom("Pretendard", size: 10))
//                    .opacity(0.6)
//                    .frame(width: 32, height: 40, alignment: .top)
//            }
//        }
//        .foregroundStyle(Color.black)
//    }
//}
//
///// 실제 시간표 그리드를 표시하는 뷰
//private struct TimetableGrid: View {
//    let days: [String]
//    let hours: [String]
//    
//    var body: some View {
//        GeometryReader { geometry in
//            HStack(spacing: 0) {
//                
//
//                
//                ForEach(days, id: \.self) { day in
//                    DayColumn(day: day,
//                             hoursCount: hours.count,
//                             columnWidth: geometry.size.width / CGFloat(days.count))
//                }
//            }
//            .foregroundStyle(Color.black)
//            
//            // 여기에 강의 블록을 추가할 수 있습니다.
//            // LectureBlocksView(geometry: geometry)
//        }
//    }
//}
//
///// 개별 요일 열
//private struct DayColumn: View {
//    let day: String
//    let hoursCount: Int
//    let columnWidth: CGFloat
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            // 요일 라벨
//            Text(day)
//                .font(.system(size: 12, weight: .semibold))
//                .frame(width: columnWidth, height: 40)
//                .frame(maxWidth: .infinity, alignment: .top)
//                .opacity(0.9)
//            
//            // 시간 슬롯들
//            ForEach(0..<hoursCount, id: \.self) { _ in
//                Rectangle()
//                    .stroke(Color.black, lineWidth: 0.5)
//                    .frame(height: 40)
//            }
//        }
//    }
//}
//
//// MARK: - Helper Functions
//
//private extension TimetableView {
//    func makeTimeBlock(lectures: [Lecture]) -> [(Lecture, [Int], [String])] {
//        var result: [(Lecture, [Int], [String])] = []
//        
//        for lecture in lectures {
//            let lectTimes = lecture.time.split(separator: " ").map { String($0) }
//            var period = [Int]()
//            var firstTimes = [String]()
//            var count = 1
//            
//            for i in 0..<lectTimes.count-1 {
//                if let nextTime = nextNumberString(from: String(lectTimes[i])),
//                   nextTime == String(lectTimes[i+1]) {
//                    count += 1
//                } else {
//                    period.append(count)
//                    firstTimes.append(lectTimes[i - count + 1])
//                    count = 1
//                }
//            }
//            
//            period.append(count)
//            firstTimes.append(lectTimes[lectTimes.count - count])
//            result.append((lecture, period, firstTimes))
//        }
//        
//        return result
//    }
//    
//    func nextNumberString(from string: String) -> String? {
//        let day = String(string.prefix(1))
//        let numberString = String(string.substring(from: 1))
//        guard let number = Int(numberString) else { return nil }
//        return "\(day)\(number + 1)"
//    }
//    
//    func getDayIndex(day: String) -> Int {
//        switch day {
//        case "월": return 0
//        case "화": return 1
//        case "수": return 2
//        case "목": return 3
//        case "금": return 4
//        case "토": return 5
//        default: return 0
//        }
//    }
//    
//    func getPeriodIndex(period: String) -> Int {
//        return (Int(period) ?? 1)
//    }
//}
//
//// MARK: - String Extension
//
//extension String {
//    func substring(from index: Int) -> String {
//        let startIndex = self.index(self.startIndex, offsetBy: index)
//        return String(self[startIndex...])
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    TimetableView()
//}
