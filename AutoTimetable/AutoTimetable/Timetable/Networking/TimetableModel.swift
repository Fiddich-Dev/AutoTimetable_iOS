//
//  Lecture.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/5/25.
//

import Foundation


struct Lecture: Codable, Hashable, Identifiable, Equatable {
    var id: Int64
    var codeSection: String
    var name: String
    var professor: String
    var type: String
    var credit: String
    var notice: String
    var time: String
}

struct LectureTimeInfo: Identifiable {
    let id = UUID()
    let lecture: Lecture
    let startTime: String
    let endTime: String
}

struct YearAndSemester: Hashable, Codable {
    var year: String
    var semester: String
}


struct Timetable: Codable {
    var id: Int64
    var year: String
    var semester: String
    var isRepresent: Bool
    var lectures: [Lecture]
}

struct CreatedTimetable: Codable, Hashable {
    var year: String
    var semester: String
    var timeTableName: String
    var isRepresent: Bool
    var lectures: [Lecture]
}

struct Category: Codable, Hashable {
    let id: String
    let name: String
    let order: String
    let parentId: String
}

struct YearSemester: Identifiable {
    let id = UUID()
    let year: String
    let semester: String // 1 or 2
}

func getCurrentYearSemester(date: Date = Date()) -> YearSemester {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month], from: date)

    guard let year = components.year, let month = components.month else {
        return YearSemester(year: "error", semester: "error") // fallback
    }

    let semester: Int
    switch month {
    case 1...6:
        semester = 1
    case 7...12:
        semester = 2
    default:
        semester = 99
    }

    return YearSemester(year: String(year), semester: String(semester))
}


struct SearchLectureRequest: Codable {
    var type: String = "name"
    var keyword: String = ""
    var year: String = "2025"
    var semester: String = ""
    var page: Int = 0
    var size: Int = 50
}


struct GenerateTimetableOption: Codable {
    var year: String
    var semester: String
    var targetMajorCnt: Int
    var targetCultureCnt: Int
    var likeOfficialLectureCodeSection: [String]
    var dislikeOfficialLectureCodeSection: [String]
    var categoryIds: [String]
    var usedTime: [[Int]]
    var minCredit: Int
    var maxCredit: Int
    var preferMorning: Bool
    var preferAfternoon: Bool
}


extension Lecture {
    func lectureTimeInfos(forWeekday weekday: String) -> [LectureTimeInfo] {
        let timeSlots = time.components(separatedBy: ",")
        var result: [LectureTimeInfo] = []

        for slot in timeSlots {
            guard String(slot.prefix(1)) == weekday,
                  slot.count >= 9 else { continue }

            let timeRange = String(slot.dropFirst())
            let times = timeRange.components(separatedBy: "-")
            guard times.count == 2 else { continue }

            result.append(LectureTimeInfo(
                lecture: self,
                startTime: Lecture.formatTimeString(times[0]),
                endTime: Lecture.formatTimeString(times[1])
            ))
        }

        return result
    }

    static func formatTimeString(_ time: String) -> String {
        guard time.count == 4,
              let hour = Int(time.prefix(2)),
              let minute = Int(time.suffix(2)) else {
            return time
        }
        return String(format: "%02d:%02d", hour, minute)
    }
}
