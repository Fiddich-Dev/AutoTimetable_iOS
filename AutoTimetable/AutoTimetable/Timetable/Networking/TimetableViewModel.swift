//
//  TimetableViewModel.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/13/25.
//

import Foundation
import Moya

// 응답확인하기
//let rawString = String(data: response.data, encoding: .utf8)
//print("서버 응답: \(rawString ?? "nil")")
//print(response)

// 변수 정리
class TimetableViewModel: ObservableObject {
    
    
    private var provider: MoyaProvider<TimetableApi>!
    
    // 날짜로 학년도 정보 가져오기
    var currentYearSemester: YearSemester = getCurrentYearSemester()
    
    // 시간표가 존재하는 학년도 정보
    @Published var yearAndSemesters: [YearAndSemester] = []
    
    // 키워드로 검색된 강의들
    @Published var searchLectures: [Lecture] = []
    // 선택된 강의들
    @Published var selectedLectures: [Lecture] = []
    
    // 사용중인 시간, published는 잘 모르겠다
    @Published var usedTime = Array(repeating: Array(repeating: 0, count: 1440), count: 7)
    
    // 모든 학과 정보
    var allDepartments: [Department] = []
    
    // 메인 시간표
    @Published var mainTimetable: Timetable?
    
    @Published var timetableAboutYearAndSemester: [Timetable] = []
    @Published var errorAlert: Bool = false
    
    @Published var savedTimetableId: Int64 = -1
    
    @Published var selectedYear = "";
    @Published var selectedSemester = "";
    
    
    init(viewModel: AuthViewModel) {
        let authPlugin = AuthPlugin(viewModel: viewModel)
        self.provider = MoyaProvider<TimetableApi>(plugins: [authPlugin])
        loadInitialYearSemester()
    }
    

    func getYearAndSemester() {
        provider.request(.getYearAndSemester) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let apiResponse = try? response.map(ApiResponse<[YearAndSemester]>.self), let yearAndSemester = apiResponse.content {
                        print("✅ getYearAndSemester매핑 성공")
                        
                        self.yearAndSemesters = yearAndSemester
                    }
                    else {
                        print("🚨 getYearAndSemester매핑 실패")
                    }
                case .failure:
                    print("🚨 getYearAndSemester네트워크 요청 실패")
                }
            }
        }
    }
    // 완료
    func putTimetableLectures(timetableId: Int64, lectureIds: [Int64], completion: @escaping () -> Void) {
        provider.request(.putTimetableLectures(timetableId: timetableId, lectureIds: lectureIds)) { result in
            DispatchQueue.main.async {
                if case .success(let response) = result,
                   let apiResponse = try? response.map(ApiResponse<EmptyContent>.self),
                   apiResponse.statusCode.uppercased() == "OK" {
                    print("✅ putTimetableLectures 성공: \(apiResponse.message)")
                    completion()
                } else {
                    print("❌ putTimetableLectures 실패 또는 매핑 실패")
                }
            }
            
        }
    }
    // 완료
    func getTimetablesByYearAndSemester(year: String, semester: String, completion: @escaping () -> Void) {
        provider.request(.getTimetablesByYearAndSemester(year: year, semester: semester)) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let apiResponse = try? response.map(ApiResponse<[Timetable]>.self), let timetable = apiResponse.content {
                        print("✅ getTimetablesByYearAndSemester매핑 성공")
                        self.timetableAboutYearAndSemester = timetable
                        
                        completion()
                    }
                    else {
                        print("🚨 getTimetablesByYearAndSemester매핑 실패")
                    }
                case .failure:
                    print("🚨 getTimetablesByYearAndSemester네트워크 요청 실패")
                }
            }
        }
    }
    
    // 완료
    func getMainTimetableByYearAndSemester(year: String, semester: String) {
        provider.request(.getMainTimetableByYearAndSemester(year: year, semester: semester)) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    guard let apiResponse = try? response.map(ApiResponse<Timetable?>.self) else {
                        print("🚨 JSON 파싱 실패")
                        self.mainTimetable = nil
                        return
                    }

                    if let timetable = apiResponse.content {
                        self.mainTimetable = timetable
                        print("✅ 메인 시간표 로드 성공")
                    } else {
                        self.mainTimetable = nil
                        print("ℹ️ 메인 시간표 없음 (content == nil)")
                    }

                case .failure(let error):
                    print("🚨 네트워크 요청 실패: \(error.localizedDescription)")
                    self.mainTimetable = nil
                }
            }
        }
    }

    // 완료
    func patchMainTimetable(timetableId: Int64, completion: @escaping () -> Void) {
        provider.request(.patchMainTimetable(timetableId: timetableId)) { result in
            DispatchQueue.main.async {
                if case .success(let response) = result,
                   let apiResponse = try? response.map(ApiResponse<EmptyContent>.self),
                   apiResponse.statusCode.uppercased() == "OK" {
                    print("✅ patchMainTimetable 성공: \(apiResponse.message)")
                    completion()
                } else {
                    print("🚨 patchMainTimetable 실패 또는 매핑 실패")
                }
            }
            
        }
    }
    // 완료
    func deleteTimetable(timetableId: Int64, completion: @escaping () -> Void) {
        provider.request(.deleteTimetable(timetableId: timetableId)) { result in
            DispatchQueue.main.async {
                if case .success(let response) = result,
                   let apiResponse = try? response.map(ApiResponse<EmptyContent>.self),
                   apiResponse.statusCode.uppercased() == "OK" {
                    print("✅ deleteTimetable 성공: \(apiResponse.message)")
                    completion()
                } else {
                    print("🚨 deleteTimetable 실패 또는 매핑 실패")
                }
            }
        }
    }

    // 완료
    func searchLectures(keyword: String) {
        if(keyword.isEmpty) {
            searchLectures = []
            return
        }
        provider.request(.searchLectures(keyword: keyword)) { result in
            switch result {
            case .success(let response):
//                let rawString = String(data: response.data, encoding: .utf8)
//                print("서버 응답: \(rawString ?? "nil")")
//                print(response)
                
                if let apiResponse = try? response.map(ApiResponse<[Lecture]>.self), let searchLectures = apiResponse.content {
                    print("✅ searchLectures매핑 성공")
                    
                    self.searchLectures = searchLectures
                    
                }
                else {
                    print("🚨 searchLectures매핑 실패")
                }
            case .failure:
                print("🚨 searchLectures네트워크 요청 실패")
            }
        }
    }

    
    
    // 여기부터 네트워크 통신 아님
    
    func fillUsedTime(timeString: String) {
        
        let dayMap: [String: Int] = ["월": 0, "화": 1, "수": 2, "목": 3, "금": 4, "토": 5, "일": 6]
        let timeBlocks = timeString.split(separator: ",")
        
        for block in timeBlocks {
            let daySymbol = String(block.prefix(1))  // 예: "월"
            guard let dayIndex = dayMap[daySymbol] else { continue }
            
            let rangeString = block.dropFirst()  // "900-1015"
            let parts = rangeString.split(separator: "-")
            guard parts.count == 2,
                  let start = Int(parts[0]),
                  let end = Int(parts[1]) else { continue }
            
            let startMin = (start / 100) * 60 + (start % 100)
            let endMin = (end / 100) * 60 + (end % 100)
            
            for minute in startMin..<endMin {
                self.usedTime[dayIndex][minute] = 1
            }
        }
    }
    
    func emptyUsedTime(timeString: String) {
        
        let dayMap: [String: Int] = ["월": 0, "화": 1, "수": 2, "목": 3, "금": 4, "토": 5, "일": 6]
        let timeBlocks = timeString.split(separator: ",")
        
        for block in timeBlocks {
            let daySymbol = String(block.prefix(1))  // 예: "월"
            guard let dayIndex = dayMap[daySymbol] else { continue }
            
            let rangeString = block.dropFirst()  // "900-1015"
            let parts = rangeString.split(separator: "-")
            guard parts.count == 2,
                  let start = Int(parts[0]),
                  let end = Int(parts[1]) else { continue }
            
            let startMin = (start / 100) * 60 + (start % 100)
            let endMin = (end / 100) * 60 + (end % 100)
            
            for minute in startMin..<endMin {
                self.usedTime[dayIndex][minute] = 0
            }
        }
    }
    
    func canAddLectureAboutTime(timeString: String) -> Bool {
        let dayMap: [String: Int] = ["월": 0, "화": 1, "수": 2, "목": 3, "금": 4, "토": 5, "일": 6]
        let timeBlocks = timeString.split(separator: ",")
        
        for block in timeBlocks {
            let daySymbol = String(block.prefix(1))  // 예: "월"
            guard let dayIndex = dayMap[daySymbol] else { continue }
            
            let rangeString = block.dropFirst()  // "900-1015"
            let parts = rangeString.split(separator: "-")
            guard parts.count == 2,
                  let start = Int(parts[0]),
                  let end = Int(parts[1]) else { continue }
            
            let startMin = (start / 100) * 60 + (start % 100)
            let endMin = (end / 100) * 60 + (end % 100)
            
            for minute in startMin..<endMin {
                if(self.usedTime[dayIndex][minute] == 1) {
                    return false
                }
            }
        }
        return true
    }
    
    func loadInitialYearSemester() {
            self.currentYearSemester = getCurrentYearSemester()
        }
    
    // 강의들을 받아서 usedtime채우기
    func fillUsedTimeAboutLecturesTime(lecturesTime: [String]) {
        for lectureTime in lecturesTime {
            fillUsedTime(timeString: lectureTime)
        }
    }
    
}



struct LectureCount {
    var major: Int
    var culture: Int
}

