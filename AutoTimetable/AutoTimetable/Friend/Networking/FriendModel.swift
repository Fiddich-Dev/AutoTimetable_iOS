//
//  FriendModel.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/10/25.
//

import Foundation


struct Friend: Codable, Hashable {
    var id: Int64
    var studentId: String
    var profileImage: String?
    var username: String
//    var school: String
//    var department: String
}


enum SearchFriendStatus: String, Codable {
    case alreadyFriend = "ALREADY_FRIEND"
    case pending = "PENDING"
    case notFriend = "NOT_FRIEND"
}

struct SearchMemberDTO: Codable, Identifiable, Hashable {
    let id: Int64
    let studentId: String
    let username: String
    var status: SearchFriendStatus
}

struct CompareTimetableDto: Codable {
    var id: Int64 { lecture.id }
    var lecture: Lecture
    var usernames: [String] = []
    var studentIds: [String] = []
    
    enum CodingKeys: String, CodingKey {
        case lecture = "internalLectureDto"
        case usernames
        case studentIds
    }
}
