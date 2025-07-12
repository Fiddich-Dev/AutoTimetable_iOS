//
//  GenerateTimetableViewModel.swift
//  AutoTimetable
//
//  Created by 황인성 on 7/4/25.
//

import Foundation
import Moya

class GenerateTimetableViewModel: ObservableObject {
    
    private var provider: MoyaProvider<TimetableApi>!
    
    // 날짜로 학년도 정보 가져오기
    var currentYearSemester: YearSemester = getCurrentYearSemester()
    
    // 모든 학과 정보
    var allDepartments: [Department] = []
    
    // 키워드로 검색된 강의들
    @Published var searchLectures: [Lecture] = []
    
    // --------에타매핑에 필요한 정보들-----------
    // 에브리타임에서 가져온 시간표, 변경안됨
    @Published var mappedTimetables: [ExternalTimetable] = []
    
    // --------수동생성에 필요한 정보들-----------
    @Published var customTimetable: [Lecture] = []
    
    
    // --------자동생성에 필요한 정보들-----------
    // 목표 교양과목 수
    @Published var targetCultureCnt: Int = 0
    // 목표 전공과목 수
    @Published var targetMajorCnt: Int = 0
    // 사용자가 선택한 학과들
    @Published var selectedDepartments: [Department] = []
    // 사용자가 선택한 제외할 강의들
    @Published var selectedDislikeLectures: [Lecture] = []
    // 사용자가 선택한 포함할 강의들
    @Published var selectedLikeLectures: [Lecture] = []
    // 사용중인 시간, published는 잘 모르겠다
    @Published var usedTime = Array(repeating: Array(repeating: 0, count: 1440), count: 7)
    @Published var minCredit: Int = 0
    @Published var maxCredit: Int = 24
    @Published var preferMorning: Bool = false
    @Published var preferAfternoon: Bool = false
    
    // 자동생성기로 생성된 시간표들
    @Published var makedTimetables: [[Lecture]] = []
    
    init() {
        self.provider = MoyaProvider<TimetableApi>()
    }
    
    func generateTimetable(targetMajorCnt: Int, targetCultureCnt: Int, likeLectureCode: [Int64], dislikeLectureCode: [Int64], categoryIds: [Int64], usedTime: [[Int]], minCredit: Int, maxCredit: Int, preferMorning: Bool, preferAfternoon: Bool) {
        provider.request(.generateTimetable(targetMajorCnt: targetMajorCnt, targetCultureCnt: targetCultureCnt, likeLectureCode: likeLectureCode, dislikeLectureCode: dislikeLectureCode, categoryIds: categoryIds, usedTime: usedTime, minCredit: minCredit, maxCredit: maxCredit, preferMorning: preferMorning, preferAfternoon: preferAfternoon)) { result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let apiResponse = try? response.map(ApiResponse<[[Lecture]]>.self), let makedTimetables = apiResponse.content {
                        print("✅ generateTimetable매핑 성공")
                        print(makedTimetables.count);
                        
                        // 없어도 한개가 나옴?
                        if(makedTimetables.count == 1 && makedTimetables[0].isEmpty) {
                            
                        }
                        else {
                            self.makedTimetables = makedTimetables
                        }
                        
                    }
                    else {
                        print("🚨 generateTimetable매핑 실패")
                    }
                case .failure:
                    print("🚨 generateTimetable네트워크 요청 실패")
                }
            }
            
        }
    }

    
    func getAllDepartments(year: String, semester: String) {
        provider.request(.getAllDepartment(year: year, semester: semester)) { result in
            switch result {
            case .success(let response):
                if let apiResponse = try? response.map(ApiResponse<[Department]>.self), let allDepartments = apiResponse.content {
                    print("✅ getAllDepartments매핑 성공")
                    
                    self.allDepartments = allDepartments
                    print(allDepartments.count)
                    
                }
                else {
                    print("🚨 getAllDepartments매핑 실패")
                }
            case .failure:
                print("🚨 getAllDepartments네트워크 요청 실패")
            }
        }
    }
    
    func searchLectures(keyword: String) {
        if(keyword.isEmpty) {
            return
        }
        provider.request(.searchLectures(keyword: keyword)) { result in
            switch result {
            case .success(let response):
                if let apiResponse = try? response.map(ApiResponse<[Lecture]>.self), let searchLectures = apiResponse.content {
                    print("✅ searchLectures매핑 성공")
                    
                    self.searchLectures = searchLectures
                    
                }
                else {
                    print("🚨 searchLectures매핑 실패")
                    self.searchLectures = []
                }
            case .failure:
                print("🚨 searchLectures네트워크 요청 실패")
                self.searchLectures = []
            }
        }
    }
    
    func saveTimetable(year: String, semester: String, timeTableName: String, isRepresent: Bool, selectedLectureIds: [Int64], completion: @escaping () -> Void) {
        provider.request(.saveTimetable(year: year, semester: semester, timeTableName: timeTableName, isRepresent: isRepresent, selectedLectureIds: selectedLectureIds)) { result in
            DispatchQueue.main.async {
                if case .success(let response) = result,
                   let apiResponse = try? response.map(ApiResponse<Int64>.self),
                   apiResponse.statusCode.uppercased() == "OK", let savedTimetableId = apiResponse.content {
                    print("✅ saveTimetable 성공: \(apiResponse.message)")
                    completion()
                } else {
                    print("🚨 saveTimetable 실패 또는 매핑 실패")
                }
            }
            
        }
    }
    
    // 완료
    func getAllEverytimetable(url: String) {
        provider.request(.getAllEverytimetable(url: url)) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    
                    let rawString = String(data: response.data, encoding: .utf8)
                    print("서버 응답: \(rawString ?? "nil")")
                    print(response)
                    
                    if let apiResponse = try? response.map(ApiResponse<[ExternalTimetable]>.self), let mappedTimetables = apiResponse.content {
                        print("✅ getAllEverytimetable매핑 성공")
                        print(mappedTimetables.count);
                        
                        self.mappedTimetables = mappedTimetables
                        
                    }
                    else {
                        print("🚨 getAllEverytimetable매핑 실패")
                    }
                case .failure:
                    print("🚨 getAllEverytimetable네트워크 요청 실패")
                }
            }
        }
    }
    
    // 완료
    func saveEverytimetable(year: String, semester: String, timetableName: String, isRepresent: Bool, lectures: [ExternalLecture], completion: @escaping () -> Void) {
        provider.request(.saveEverytimetable(year: year, semester: semester, timetableName: "에타에서", isRepresent: isRepresent, lectures: lectures)) { result in
            DispatchQueue.main.async {
                if case .success(let response) = result,
                   let apiResponse = try? response.map(ApiResponse<EmptyContent>.self),
                   apiResponse.statusCode.uppercased() == "OK" {
                    print("✅ saveEvertimetable 성공: \(apiResponse.message)")
                    completion()
                } else {
                    print("🚨 saveEvertimetable 실패 또는 매핑 실패")
                }
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
    
}
