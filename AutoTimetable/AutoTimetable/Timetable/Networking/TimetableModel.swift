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
struct Lecture: Codable, Hashable, Identifiable {
    var id: Int64
    var code: String
    var codeSection: String
    var name: String
    var professor: String
    var type: String
    var time: String
    var place: String
    var credit: String
    var target: String
    var notice: String
    var department: String
}




