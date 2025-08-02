//
//  TimetableApi.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/13/25.
//

import Foundation
import Moya




enum TimetableApi {
    case saveTimetable(createdTimetable: CreatedTimetable)
    case getTimetablesByYearAndSemester(year: String, semester: String)
    case getYearAndSemester
    case generateTimetable(generateTimetableOption: GenerateTimetableOption)
    case putTimetableLectures(timetableId: Int64, lectures: [Lecture])
    case deleteTimetable(timetableId: Int64)
    case getMainTimetableByYearAndSemester(year: String, semester: String)
    case patchMainTimetable(timetableId: Int64)
    case getAllEverytimetable(url: String)
    case saveEverytimetable(year: String, semester: String, timetableName: String, isRepresent: Bool, lectures: [Lecture])
//    case getAllLectures
    case searchLectures(keyword: String)
    case getAllDepartment(year: String, semester: String)
    
    case getEverytimeCategories(year: String, semester: String)
    case searchEverytimeLectures(type: String, keyword: String, year: String ,semester: String, page: Int, size: Int)
}


extension TimetableApi: TargetType {
    
    
    public var baseURL: URL {
        URL(string: "https://ssku.shop")!
//        URL(string: "http://localhost:8080")!
    }
    
    public var path: String {
        switch self {
            
        case .saveTimetable:
            return "/timetables"
        case .getTimetablesByYearAndSemester:
            return "/timetables"
        case .getYearAndSemester:
            return "/timetables/periods"
        case .generateTimetable:
            return "/timetables/auto-generate"
        case .putTimetableLectures(let timetableId, let lectures):
            return "/timetables/\(timetableId)"
        case .deleteTimetable(let timetableId):
            return "/timetables/\(timetableId)"
        case .getMainTimetableByYearAndSemester:
            return "/timetables/main"
        case .patchMainTimetable:
            return "/timetables/main"
        case .getAllEverytimetable:
            return "/everytime/timetables"
        case .saveEverytimetable:
            return "/timetables/everytime"
//        case .getAllLectures:
//            return "/timetables"
        case .searchLectures:
            return "/lectures/search"
        case .getAllDepartment:
            return "/categories"
            
        case .getEverytimeCategories:
            return "/everytime/categories"
        case .searchEverytimeLectures:
            return "/everytime/lectures/search"
        }
    }
    
    var method: Moya.Method {
        switch self {

        case .saveTimetable:
            return .post
        case .getTimetablesByYearAndSemester:
            return .get
        case .getYearAndSemester:
            return .get
        case .generateTimetable:
            return .post
        case .putTimetableLectures:
            return .put
        case .deleteTimetable:
            return .delete
        case .getMainTimetableByYearAndSemester:
            return .get
        case .patchMainTimetable:
            return .patch
        case .getAllEverytimetable:
            return .get
        case .saveEverytimetable:
            return .post
//        case .getAllLectures:
//            return .get
        case .searchLectures:
            return .get
        case .getAllDepartment:
            return .get
        case .getEverytimeCategories:
            return .get
        case .searchEverytimeLectures:
            return .get
        }
    }
    
    
    
    var task: Moya.Task {
        switch self {
            
        case .saveTimetable(let timetable):
            return .requestJSONEncodable(timetable)
        case .getTimetablesByYearAndSemester(year: let year, semester: let semester):
            return .requestParameters(parameters: ["year": year, "semester": semester], encoding: URLEncoding.default)
        case .getYearAndSemester:
            return .requestPlain
        case .generateTimetable(let generateTimetableOption):
            return .requestJSONEncodable(generateTimetableOption)
        case .putTimetableLectures(let timetableId, let lectures):
            return .requestJSONEncodable(lectures)
        case .deleteTimetable:
            return .requestPlain
        case .getMainTimetableByYearAndSemester(let year, let semester):
            return .requestParameters(parameters: ["year": year, "semester": semester], encoding: URLEncoding.default)
        case .patchMainTimetable(let timetableId):
            return .requestParameters(parameters: ["timetableId": timetableId], encoding: JSONEncoding.default)
        case .getAllEverytimetable(let url):
            return .requestParameters(parameters: ["url": url], encoding: URLEncoding.default)
        case .saveEverytimetable(let year, let semester, let timetableName, let isRepresent, let lectures):
            let lecturesArray = lectures.map { lecture in
                return [
                    "subjectId": lecture.id,
                    "code": lecture.codeSection,
                    "codeSection": lecture.codeSection,
                    "name": lecture.name,
                    "professor": lecture.professor,
                    "time": lecture.time,
                    "credit": lecture.credit
                ]
            }
            return .requestParameters(parameters: ["year": year, "semester": semester, "timetableName": timetableName, "isRepresent": isRepresent, "lectures": lecturesArray], encoding: JSONEncoding.default)
            //        case .getAllLectures:
            //            return .requestPlain
        case .searchLectures(let keyword):
            return .requestParameters(parameters: ["keyword": keyword], encoding: URLEncoding.default)
        case .getAllDepartment(let year, let semester):
            return .requestParameters(parameters: ["year": year, "semester": semester], encoding: URLEncoding.default)
        case .getEverytimeCategories(year: let year, semester: let semester):
            return .requestParameters(parameters: ["year": year, "semester": semester], encoding: URLEncoding.default)
        case .searchEverytimeLectures(let type, let keyword, let year, let semester, let page, let size):
            return .requestParameters(parameters:
                                        ["type": type,
                                         "keyword": keyword,
                                         "year": year,
                                         "semester": semester,
                                         "page": page,
                                         "size": size
                                        ], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {

        case .saveTimetable:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .getTimetablesByYearAndSemester:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .getYearAndSemester:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .generateTimetable:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .putTimetableLectures:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .deleteTimetable:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .getMainTimetableByYearAndSemester:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .patchMainTimetable:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .getAllEverytimetable:
            return ["Content-type": "application/json"]
        case .saveEverytimetable:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
//        case .getAllLectures:
//            return ["Content-type": "application/json"]
        case .searchLectures:
            return ["Authorization": "Bearer \(getToken() ?? "asd")"]
        case .getAllDepartment:
            return ["Content-type": "application/json"]
        case .getEverytimeCategories:
            return ["Content-type": "application/json"]
        case .searchEverytimeLectures:
            return ["Content-type": "application/json"]
        }
    }
    
    private func getToken() -> String? {
        return KeychainHelper.shared.read(forKey: "accessToken")
    }
    private func getRefreshToken() -> String? {
        return KeychainHelper.shared.read(forKey: "refreshToken")
    }
}
