//
//  GenerateTimetableViewModel.swift
//  AutoTimetable
//
//  Created by 황인성 on 7/4/25.
//

import Foundation
import Moya

class GenerateTimetableViewModel: ObservableObject {
    
    // MARK: 에타매핑에 필요한 정보들
    // 에브리타임에서 가져온 시간표, 변경안됨
    @Published var mappedTimetables: [CreatedTimetable] = []
    
    
    // MARK: 수동생성에 필요한 정보들
    @Published var customTimetableLectures: [Lecture] = []
    
    
    // MARK: 자동생성에 필요한 정보들
    // 사용자가 선택한 학과들
    @Published var selectedDepartments: [Category] = []
    // 목표 교양과목 수
    @Published var targetCultureCnt: Int = 0
    // 목표 전공과목 수
    @Published var targetMajorCnt: Int = 0
    // 필터링 조건
    @Published var minCredit: Int = 0
    @Published var maxCredit: Int = 24
    @Published var preferMorning: Bool = false
    @Published var preferAfternoon: Bool = false
    // 사용자가 선택한 제외할 강의들
    @Published var selectedDislikeLectures: [Lecture] = []
    // 사용자가 선택한 포함할 강의들
    @Published var selectedLikeLectures: [Lecture] = []
    // 사용중인 시간, published는 잘 모르겠다
    @Published var usedTime = Array(repeating: Array(repeating: 0, count: 1440), count: 7)
    // 자동생성기로 생성된 시간표들
    @Published var makedTimetablesLectures: [[Lecture]] = []
    
    
    // MARK: 검색
    // 학과 검색, 선택
    var allCategories: [Category] = []
    @Published var selectedCategories: [Category] = []
    
    // 강의 페이징 검색
    @Published var selectedLectures: [Lecture] = []
    @Published var selectedLecturesWithUsedTime: [Lecture] = []
    
    // 강의 검색 공통 페이징 옵션
    @Published var searchedLectures: [Lecture] = []
    @Published var isSearchLectureLoading = false
    @Published var isSearchLectureLastPage = false
    var searchLecturePage: Int = 0
    
    
    @Published var isLoading: Bool = false
    
    
    private var provider: MoyaProvider<TimetableApi>!

    
    init() {
        self.provider = MoyaProvider<TimetableApi>()
    }
    
    func fetchEverytimeCategories(year: String, semester: String) {
        provider.request(.getEverytimeCategories(year: year, semester: semester)) { result in
            switch result {
            case .success(let response):                
                if let apiResponse = try? response.map(ApiResponse<[Category]>.self), let allCategories = apiResponse.content {
                    print("✅ fetchEverytimeCategories매핑 성공")
                    self.allCategories = allCategories
                }
                else {
                    print("🚨 fetchEverytimeCategories매핑 실패")
                }
            case .failure:
                print("🚨 fetchEverytimeCategories네트워크 요청 실패")
            }
        }
    }
    
    // -----페이징-------
    
    func searchEverytimeLectures(type: String, keyword: String, year: String, semester: String, page: Int, size: Int) {
        
        provider.request(.searchEverytimeLectures(type: type, keyword: keyword, year: year, semester: semester, page: page, size: size)) { result in
            DispatchQueue.main.async {
                
                defer { self.isSearchLectureLoading = false }
                
                switch result {
                case .success(let response):
                    if let apiResponse = try? response.map(ApiResponse<[Lecture]>.self), let searchedLectures = apiResponse.content {
                        if(searchedLectures.isEmpty) {
                            self.isSearchLectureLastPage = true
                            print("✅ 마지막 페이지")
                        } else {
                            self.searchedLectures.append(contentsOf: searchedLectures)
                            print("✅ searchEverytimeLectures매핑 성공")
                        }
                    }
                    else {
                        print("🚨 searchEverytimeLectures매핑 실패")
                        self.resetSearchState()
                    }
                case .failure:
                    print("🚨 searchEverytimeLectures네트워크 요청 실패")
                    self.resetSearchState()
                }
            }
        }
    }
    
    func resetSearchState() {
        self.searchedLectures = []
        self.searchLecturePage = 0
        self.isSearchLectureLoading = false
        self.isSearchLectureLastPage = false
    }
    
    // -----페이징-------

    
    func generateTimetable(generateTimetableOption: GenerateTimetableOption) {
        provider.request(.generateTimetable(generateTimetableOption: generateTimetableOption)) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    
                    let rawString = String(data: response.data, encoding: .utf8)
                    print("서버 응답: \(rawString ?? "nil")")
                    print(response)
                    
                    if let apiResponse = try? response.map(ApiResponse<[[Lecture]]>.self), let makedTimetablesLectures = apiResponse.content {
                        print("✅ generateTimetable매핑 성공")
                        print(makedTimetablesLectures.count);
                        
                        print(makedTimetablesLectures[2].count)
                        
                        // 없어도 한개가 나옴?
                        if(makedTimetablesLectures.count == 1 && makedTimetablesLectures[0].isEmpty) {
                            
                        }
                        else {
                            self.makedTimetablesLectures = makedTimetablesLectures
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

    func saveTimetable(createdTimetable: CreatedTimetable, completion: @escaping () -> Void) {
        provider.request(.saveTimetable(createdTimetable: createdTimetable)) { result in
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
                    
                    if let apiResponse = try? response.map(ApiResponse<[CreatedTimetable]>.self), let mappedTimetables = apiResponse.content {
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
    
    
    
    // MARK: 여기부터 네트워크 통신 아님
    
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
    
}
