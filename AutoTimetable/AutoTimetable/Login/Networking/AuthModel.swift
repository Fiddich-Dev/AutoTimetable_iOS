//
//  AuthModel.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/5/25.
//

import Foundation

struct ApiResponse<T: Decodable>: Decodable {
    let statusCode: String
    let message: String
    let content: T?
}


struct EmptyContent: Decodable {}


struct Token: Codable {
    var access: String
    var refresh: String
}

func studentIdToEmail(studentId: String) -> String {
    return "\(studentId)@g.skku.edu"
}






