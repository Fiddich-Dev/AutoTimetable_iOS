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
    var school: String
    var department: String
}
