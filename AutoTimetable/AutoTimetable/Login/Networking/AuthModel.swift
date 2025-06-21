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

struct LoginResponse: Codable {
    var statusCode: String
    var message: String
    var content: Token
}

struct School: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

let schoolList = [
    School(name: "성균관대학교"),
    School(name: "서울대학교"),
    School(name: "고려대학교"),
    School(name: "연세대학교"),
    School(name: "한양대학교")
]



