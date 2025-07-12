//
//  LectureSearchBar.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/25/25.
//


import SwiftUI


struct DepartmentSearchBar: View {
    
    @Binding var allDepartments: [Department]
    @Binding var selectedDepartments: [Department]
    @Binding var searchText: String
    @FocusState private var isFocused: Bool
    
    

    var filteredDepartments: [Department] {
        if searchText.isEmpty {
            return []
        } else {
            return allDepartments.filter {$0.name.localizedCaseInsensitiveContains(searchText)}
        }
    }
    
    var departmentOverlay: some View {
        Group {
            if !filteredDepartments.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(filteredDepartments, id: \.self) { department in
                            Button(action: {
                                if !selectedDepartments.contains(department) {
                                    selectedDepartments.append(department)
                                }
                                searchText = ""
                            }) {
                                HStack {
                                    Text(department.name)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.gray)
                            }
                            .foregroundStyle(Color.black)
                            Divider()
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .frame(height: 250)
                .cornerRadius(10)
                .offset(y: 54)
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("전공/영역 을 검색하세요", text: $searchText)
                .focused($isFocused)
                .modifier(MyTextFieldModifier(isFocused: isFocused))
                .zIndex(1)

            if !selectedDepartments.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedDepartments, id: \.self) { department in
                            HStack(spacing: 4) {
                                Text(department.name)
                                Button(action: {
                                    selectedDepartments.removeAll { $0 == department }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(20)
                        }
                    }
                }
            }

        }
        .overlay(alignment: .top) {
            departmentOverlay
                .zIndex(2)
        }
    }
}


//struct AddLectureSearchBar: View {
//    @Binding var searchText: String
//    @Binding var allLectures: [Lecture]
//    @Binding var selectedLectures: [Lecture]
//
//    @FocusState private var isFocused: Bool
//    
//    @ObservedObject var timetableViewModel: TimetableViewModel
//
//    var filteredLectures: [Lecture] {
//        searchText.isEmpty ? [] : timetableViewModel.lectures.filter { $0.name.contains(searchText) }
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            TextField("듣고 싶은 강의", text: $searchText)
//                .focused($isFocused)
//                .modifier(MyTextFieldModifier(isFocused: isFocused))
//                .zIndex(1)
//
//            if !selectedLectures.isEmpty {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 8) {
//                        ForEach(selectedLectures, id: \.self) { lecture in
//                            HStack(spacing: 4) {
//                                Text(lecture.name)
//                                Button(action: {
//                                    selectedLectures.removeAll { $0 == lecture }
//                                    allLectures.append(lecture)
//                                    timetableViewModel.emptyUsedTime(timeString: lecture.time)
//                                }) {
//                                    Image(systemName: "xmark.circle.fill")
//                                        .foregroundColor(.gray)
//                                }
//                            }
//                            .padding(.horizontal, 12)
//                            .padding(.vertical, 6)
//                            .background(Color.gray.opacity(0.2))
//                            .cornerRadius(20)
//                        }
//                    }
//                }
//            }
//        }
//        .overlay(alignment: .top) {
//            if !filteredLectures.isEmpty {
//                ScrollView {
//                    VStack(spacing: 0) {
//                        ForEach(filteredLectures, id: \.self) { lecture in
//                            Button(action: {
//                                
//                                if !selectedLectures.contains(lecture) {
//                                    if !timetableViewModel.canAddLectureAboutTime(timeString: lecture.time) {
//                                        print("시간이 겹칩니다.")
//                                    }
//                                    
//                                    else {
//                                        selectedLectures.append(lecture)
//                                        allLectures.removeAll { $0 == lecture }
//                                        timetableViewModel.fillUsedTime(timeString: lecture.time)
//                                        searchText = ""
//                                    }
//                                }
//                                
//                                
//                            }) {
//                                VStack(alignment: .leading) {
//                                    Text("\(lecture.name) - \(lecture.professor)")
//                                    Text("\(lecture.codeSection)")
//                                    Text(lecture.time)
//                                }
//                                .padding()
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .background(Color.gray)
//                                
//                            }
//                            .foregroundStyle(Color.black)
//                            Divider()
//                        }
//                    }
//                    .background(Color.white)
//                    .cornerRadius(10)
//                }
//                .frame(height: 250)  // 최대 높이 제한, 필요에 따라 조절
//                .cornerRadius(10)
//                .offset(y: 54)
//            }
//        }
//    }
//}

struct LectureSearchBar: View {
    
    @Binding var searchText: String
    @Binding var selectedLectures: [Lecture]
    @Binding var searchedLectures: [Lecture]

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("강의 검색", text: $searchText)
                .focused($isFocused)
                .modifier(MyTextFieldModifier(isFocused: isFocused))
                .zIndex(1)

            if !selectedLectures.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedLectures, id: \.self) { lecture in
                            HStack(spacing: 4) {
                                Text(lecture.name)
                                Button(action: {
                                    selectedLectures.removeAll { $0 == lecture }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(20)
                        }
                    }
                }
            }
        }
        .overlay(alignment: .top) {
            if !searchedLectures.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(searchedLectures, id: \.self) { lecture in
                            Button(action: {
                                // 안고른 과목이면
                                if !selectedLectures.contains(lecture) {
                                    selectedLectures.append(lecture)
                                    searchText = ""
                                    searchedLectures = []
                                }
                                
                            }) {
                                VStack(alignment: .leading) {
                                    Text("\(lecture.name) - \(lecture.professor)")
                                    Text("\(lecture.codeSection)")
                                    Text(lecture.time)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray)
                                
                            }
                            .foregroundStyle(Color.black)
                            Divider()
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .frame(height: 250)  // 최대 높이 제한, 필요에 따라 조절
                .cornerRadius(10)
                .offset(y: 54)
            }
        }
    }
}


struct LectureSearchBarWithUsedtime: View {
    
    @Binding var searchText: String
    @Binding var selectedLectures: [Lecture]
    @Binding var searchedLectures: [Lecture]
    @Binding var usedTime: [[Int]]

    @FocusState private var isFocused: Bool
    
    @State var showAlert: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("강의 검색", text: $searchText)
                .focused($isFocused)
                .modifier(MyTextFieldModifier(isFocused: isFocused))
                .zIndex(1)

            if !selectedLectures.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedLectures, id: \.self) { lecture in
                            HStack(spacing: 4) {
                                Text(lecture.name)
                                Button(action: {
                                    selectedLectures.removeAll { $0 == lecture }
                                    emptyUsedTime(timeString: lecture.time)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(20)
                        }
                    }
                }
            }
        }
        .overlay(alignment: .top) {
            if !searchedLectures.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(searchedLectures, id: \.self) { lecture in
                            Button(action: {
                                // 안고른 과목이면
                                if !selectedLectures.contains(lecture) {
                                    // 시간이 겹치면
                                    if !canAddLectureAboutTime(timeString: lecture.time) {
                                        showAlert = true
                                    }
                                    // 시간이 안겹치면
                                    else {
                                        selectedLectures.append(lecture)
                                        fillUsedTime(timeString: lecture.time)
                                        searchText = ""
                                        searchedLectures = []
                                    }
                                }
                                
                                
                            }) {
                                VStack(alignment: .leading) {
                                    Text("\(lecture.name) - \(lecture.professor) - \(lecture.credit)학점")
                                    Text("\(lecture.codeSection)")
                                    Text(lecture.time)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray)
                                
                            }
                            .foregroundStyle(Color.black)
                            Divider()
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .frame(height: 250)  // 최대 높이 제한, 필요에 따라 조절
                .cornerRadius(10)
                .offset(y: 54)
            }
        }
        .alert("시간이 겹칩니다.", isPresented: $showAlert) {
                                Button("확인", role: .cancel) { }
                            }
    }
    
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
