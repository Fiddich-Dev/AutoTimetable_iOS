//
//  TimetableViewModel.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/13/25.
//

import Foundation
import Moya

class TimetableViewModel: ObservableObject {
    
    
    private var provider: MoyaProvider<TimetableApi>!
    var lectures: [Lecture] = []
    
    
    private var generator = TimetableGenerator()
    @Published var generatedTimetables: [[Lecture]] = []
    
    init() {
        self.provider = MoyaProvider<TimetableApi>()
    }
    
    func getAllTimetable() {
        provider.request(.getAllLectures) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let rawString = String(data: response.data, encoding: .utf8)
                    //                    print("서버 응답: \(rawString ?? "nil")")
                    //                    print(response)
                    if let apiResponse = try? response.map(ApiResponse<[Lecture]>.self), let lectures = apiResponse.content {
                        
                        print("getAllTimetable매핑 성공🚨")
                        print(lectures.count);
                        
                        self.lectures = lectures
                    }
                    else {
                        print("getAllTimetable매핑 실패🚨")
                        //                        self.LogInFailAlert = true
                    }
                case .failure:
                    print("getAllTimetable네트워크 요청 실패🚨")
                }
            }
        }
    }
    
    
    func generateTimetables(initialLecture: Lecture? = nil) {
        generator.usedTime = Array(repeating: Array(repeating: false, count: 1440), count: 7) // 초기화
        generator.makedTimetables = []
        generator.cnt = 0
        generator.totalLectures = self.lectures  // ✅ 강의 리스트 주입
        
        print("생성중")
        
        var selected: [Lecture] = []
        var count = LectureCount(major: 0, culture: 0)
        
        
        
        // 초기 강의 설정 (옵션)
        if let lecture = initialLecture {
            selected.append(lecture)
            generator.fillTime(lecture)
            generator.addCount(lecture, &count)
        }
        
        generator.generate(start: -1, selected: &selected, count: &count)
        
        // 뷰에서 사용 가능하도록 Published에 전달
        DispatchQueue.main.async {
            self.generatedTimetables = self.generator.makedTimetables
            print(self.generatedTimetables.count)
        }
    }
    
}


struct LectureCount {
    var major: Int
    var culture: Int
}

class TimetableGenerator {
    var usedTime = Array(repeating: Array(repeating: false, count: 1440), count: 7)
    var totalLectures: [Lecture] = []
    var targetMajorCount = 5
    var targetCultureCount = 1
    var makedTimetables: [[Lecture]] = []
    var cnt: Int = 0
    
    func generate(start: Int, selected: inout [Lecture], count: inout LectureCount) {
        if count.major == targetMajorCount && count.culture == targetCultureCount {
            cnt += 1
            makedTimetables.append(selected)
            return
        }
        
        for i in (start + 1)..<totalLectures.count {
            let lecture = totalLectures[i]
            if canAddCode(selected, lecture) &&
                canAddTime(lecture) &&
                canAddCount(count, lecture) {
                
                selected.append(lecture)
                fillTime(lecture)
                addCount(lecture, &count)
                
                generate(start: i, selected: &selected, count: &count)
                
                selected.removeLast()
                eraseTime(lecture)
                removeCount(lecture, &count)
            }
        }
    }
    
    func canAddCode(_ selected: [Lecture], _ lecture: Lecture) -> Bool {
        return !selected.contains(where: { $0.code == lecture.code })
    }
    
    func canAddTime(_ lecture: Lecture) -> Bool {
        for time in lecture.time.split(separator: ",") {
            guard !time.isEmpty else { continue }
            let day = dayToInt(time.first!)
            let timeRange = String(time.dropFirst())
            let parts = timeRange.split(separator: "-").map { Int($0)! }
            let start = parts[0] % 100 + (parts[0] / 100) * 60
            let end = parts[1] % 100 + (parts[1] / 100) * 60
            
            for t in start..<end {
                if usedTime[day][t] {
                    return false
                }
            }
        }
        return true
    }
    
    func canAddCount(_ count: LectureCount, _ lecture: Lecture) -> Bool {
        if lecture.department == "culture" {
            return count.culture + 1 <= targetCultureCount
        } else {
            return count.major + 1 <= targetMajorCount
        }
    }
    
    func fillTime(_ lecture: Lecture) {
        for time in lecture.time.split(separator: ",") {
            guard !time.isEmpty else { continue }
            let day = dayToInt(time.first!)
            let timeRange = String(time.dropFirst())
            let parts = timeRange.split(separator: "-").map { Int($0)! }
            let start = parts[0] % 100 + (parts[0] / 100) * 60
            let end = parts[1] % 100 + (parts[1] / 100) * 60
            
            for t in start..<end {
                usedTime[day][t] = true
            }
        }
    }
    
    func eraseTime(_ lecture: Lecture) {
        for time in lecture.time.split(separator: ",") {
            guard !time.isEmpty else { continue }
            let day = dayToInt(time.first!)
            let timeRange = String(time.dropFirst())
            let parts = timeRange.split(separator: "-").map { Int($0)! }
            let start = parts[0] % 100 + (parts[0] / 100) * 60
            let end = parts[1] % 100 + (parts[1] / 100) * 60
            
            for t in start..<end {
                usedTime[day][t] = false
            }
        }
    }
    
    func addCount(_ lecture: Lecture, _ count: inout LectureCount) {
        if lecture.department == "culture" {
            count.culture += 1
        } else {
            count.major += 1
        }
    }
    
    func removeCount(_ lecture: Lecture, _ count: inout LectureCount) {
        if lecture.department == "culture" {
            count.culture -= 1
        } else {
            count.major -= 1
        }
    }
    
    func dayToInt(_ day: Character) -> Int {
        switch day {
        case "월": return 0
        case "화": return 1
        case "수": return 2
        case "목": return 3
        case "금": return 4
        case "토": return 5
        case "일": return 6
        default: fatalError("잘못된 요일 문자: \(day)")
        }
    }
}
