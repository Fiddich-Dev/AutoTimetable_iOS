//
//  Lecture.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/5/25.
//

import Foundation

//struct Timetable: Codable {
//    var id: Int
////    var member: Member
//    var year: String
//    var semester: String
//    var timeTableName: String
//    var isRepresent: Bool
//    var lectures: [Lecture]
//}
//
//


struct Lecture: Codable, Hashable, Identifiable, Equatable {
    var id: Int64
    var code: String
    var codeSection: String
    var name: String
    var professor: String
    var type: String
    var time: String
    var credit: String
    var categoryName: String
    var notice: String
    
}

struct YearAndSemester: Hashable, Codable {
    
    var year: String
    var semester: String
}

let departmentMap: [String: String] = [
    "한문학과": "classicalChinese",
    "컴퓨터공학과": "computer_engineering",
    "전자공학과": "electrical_engineering",
    "기계공학과": "mechanical_engineering",
    "화학공학과": "chemical_engineering"
]

struct Timetable: Codable {
    var id: Int64
    var year: String
    var semester: String
    var isRepresent: Bool
    var lectures: [Lecture]
}

struct SaveTimetableDto: Codable, Hashable {
    var year: String
    var semester: String
    var timeTableName: String
    var isRepresent: Bool
    var lectures: [Lecture]
}

struct ExternalTimetable: Codable, Hashable {
    var year: String
    var semester: String
//    var timeTableName: String
    var isRepresent: Bool
    var lectures: [ExternalLecture]
}

struct ExternalLecture: Codable, Hashable {
    var subjectId: String
    var code: String
    var codeSection: String
    var name: String
    var professor: String
    var time: String
    var credit: String
}

//struct ExternalLectureDto: Codable {
//    let subjectId: String
//    let code: String
//    let codeSection: String
//    let name: String
//    let professor: String
//    let time: String
//    let credit: String
//}

struct Department: Codable, Hashable {
    let id: Int64
    let name: String
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
        semester = 1
    default:
        semester = 99
    }

    return YearSemester(year: String(year), semester: String(semester))
}



