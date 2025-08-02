//
//  LectureSearchBar.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/25/25.
//


import SwiftUI

// 학과 검색 바
struct CategorySearchBar: View {
    
    @State private var searchText: String = ""
    
    @Binding var allCategories: [Category]
    @Binding var selectedCategories: [Category]
    
    @FocusState private var isFocused: Bool
    
    var filteredCategories: [Category] {
        if searchText.isEmpty {
            return []
        } else {
            return allCategories.filter {$0.name.localizedCaseInsensitiveContains(searchText)}
        }
    }
    
    var filteredCategoriesView: some View {
        Group {
            if !filteredCategories.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(filteredCategories, id: \.self.id) { category in
                            Button(action: {
                                if !selectedCategories.contains(category) {
                                    selectedCategories.append(category)
                                }
                                searchText = ""
                            }) {
                                HStack {
                                    Text(category.name)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                            }
                            .foregroundStyle(Color.black)
                            Divider()
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .frame(maxHeight: 250)
                .cornerRadius(10)
            }
        }
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            VStack(spacing: 0) {
                TextField("전공/영역 을 검색하세요", text: $searchText)
                    .focused($isFocused)
                    .modifier(MyTextFieldModifier(isFocused: isFocused))
                    .zIndex(1)
                
                filteredCategoriesView
                
            }

            if !selectedCategories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedCategories, id: \.self.id) { category in
                            HStack(spacing: 4) {
                                Text(category.name)
                                Button(action: {
                                    selectedCategories.removeAll { $0 == category }
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
    }
}


struct LectureSearchBarWithoutUsedtime: View {
    
    @ObservedObject var viewModel: GenerateTimetableViewModel
    
    @State private var searchText: String = ""
    @State private var searchType: String = "name"
    
    @FocusState private var isFocused: Bool
    
    // 검색 기준 버튼 UI
    var searchTypeButton: some View {
        HStack(spacing: 8) {
            ForEach(["name", "professor", "code"], id: \.self) { type in
                Button(action: {
                    searchType = type
                }) {
                    Text(displayName(for: type))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(searchType == type ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(searchType == type ? .white : .black)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    // 검색 타입 문자열 → 사용자 친화적 이름
    func displayName(for type: String) -> String {
        switch type {
        case "name": return "이름"
        case "professor": return "교수"
        case "code": return "코드"
        default: return type
        }
    }
    
    // 검색 결과 뷰
    var searchedLecturesView: some View {
        Group {
            if !viewModel.searchedLectures.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.searchedLectures.indices, id: \.self) { index in
                            LazyVStack(spacing: 0) {
                                let lecture = viewModel.searchedLectures[index]
                                
                                Button(action: {
                                    if !viewModel.selectedLectures.contains(lecture) {
                                        viewModel.selectedLectures.append(lecture)
                                        searchText = ""
                                        viewModel.resetSearchState()
                                    }
                                }) {
                                    VStack(alignment: .leading) {
                                        Text("\(lecture.name) - \(lecture.professor) - \(lecture.credit)학점")
                                        Text("\(lecture.codeSection)")
                                        Text(lecture.time)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.2))
                                }
                                .foregroundStyle(Color.black)
                                .onAppear {
                                    // 마지막 행에 도달하면
                                    if(index == viewModel.searchedLectures.count - 3) {
                                        // 마지막 페이지가 아닐때
                                        if(!viewModel.isSearchLectureLoading && !viewModel.isSearchLectureLastPage) {
                                            // 페이지를 증가시킨다
                                            viewModel.searchLecturePage += 1
                                            // 증가시킨 페이지로 추가 조회
                                            viewModel.searchEverytimeLectures(type: searchType, keyword: searchText, year: "2025", semester: "2", page: viewModel.searchLecturePage, size: 50)
                                        }
                                    }
                                }
                                
                                Divider()
                            }
                        }
                        if(viewModel.isSearchLectureLoading) {
                            ProgressView()
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .frame(maxHeight: 250)
                .cornerRadius(10)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            searchTypeButton
            
            VStack(spacing: 0) {
                HStack {
                    TextField("강의 검색", text: $searchText)
                        .focused($isFocused)
                        .modifier(MyTextFieldModifier(isFocused: isFocused))
                        .zIndex(1)
                    
                    Button(action: {
                        // 없어도 될거같음
                        viewModel.resetSearchState()
                        
                        // 수동 검색 실행
                        viewModel.searchEverytimeLectures(
                            type: searchType,
                            keyword: searchText,
                            year: "2025",
                            semester: "2",
                            page: 0,
                            size: 50
                        )
                    }) {
                        Text("확인")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(searchText.count < 2 ? Color.gray.opacity(0.5) : Color.blue, lineWidth: 1)
                    )
                    .disabled(searchText.count < 2)
                }
                searchedLecturesView
            }

            // 선택된 강의들 표시
            if !viewModel.selectedLectures.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.selectedLectures.indices, id: \.self) { index in
                            let lecture = viewModel.selectedLectures[index]
                            HStack(spacing: 4) {
                                Text(lecture.name)
                                Button(action: {
                                    viewModel.selectedLectures.removeAll { $0 == lecture }
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
        // ✅ 검색 기준이 바뀌면 결과 초기화
        .onChange(of: searchType) { _ in
            viewModel.resetSearchState()
        }
        .onChange(of: searchText) { _ in
            viewModel.resetSearchState()
        }
    }
}


// 일단 시간표 생성에서만 쓰기
struct LectureSearchBarWithUsedtime: View {
    
    @ObservedObject var viewModel: GenerateTimetableViewModel
    
    @State private var searchText: String = ""
    @State private var searchType: String = "name"
    @State var showAlert: Bool = false
    
    @Binding var selectedLectures: [Lecture]
    @Binding var usedTime: [[Int]]

    @FocusState private var isFocused: Bool

    // 검색 결과 뷰
    var searchedLecturesView: some View {
        Group {
            if !viewModel.searchedLectures.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.searchedLectures.indices, id: \.self) { index in
                            LazyVStack(spacing: 0) {
                                let lecture = viewModel.searchedLectures[index]
                                
                                Button(action: {
                                    if !selectedLectures.contains(lecture) {
                                        
                                        // 시간이 겹치면
                                        if !canAddLectureAboutTime(timeString: lecture.time) {
                                            showAlert = true
                                        }
                                        // 안겹치면
                                        else {
                                            selectedLectures.append(lecture)
                                            fillUsedTime(timeString: lecture.time)
                                            searchText = ""
                                            viewModel.resetSearchState()
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
                                    .background(Color.gray.opacity(0.2))
                                }
                                .foregroundStyle(Color.black)
                                .onAppear {
                                    // 마지막 행에 도달하면
                                    if(index == viewModel.searchedLectures.count - 3) {
                                        // 마지막 페이지가 아닐때
                                        if(!viewModel.isSearchLectureLoading && !viewModel.isSearchLectureLastPage) {
                                            // 페이지를 증가시킨다
                                            viewModel.searchLecturePage += 1
                                            // 증가시킨 페이지로 추가 조회
                                            viewModel.searchEverytimeLectures(type: searchType, keyword: searchText, year: "2025", semester: "2", page: viewModel.searchLecturePage, size: 50)
                                        }
                                    }
                                }
                                
                                Divider()
                            }
                        }
                        if(viewModel.isSearchLectureLoading) {
                            ProgressView()
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .frame(maxHeight: 250)
                .cornerRadius(10)
            }
        }
    }
    
    

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            searchTypeButton
            
            VStack(spacing: 0) {
                HStack {
                    TextField("강의 검색", text: $searchText)
                        .focused($isFocused)
                        .modifier(MyTextFieldModifier(isFocused: isFocused))
                        .zIndex(1)
                    
                    Button(action: {
                        // 없어도 될거같음
                        viewModel.resetSearchState()
                        
                        // 수동 검색 실행
                        viewModel.searchEverytimeLectures(
                            type: searchType,
                            keyword: searchText,
                            year: "2025",
                            semester: "2",
                            page: 0,
                            size: 50
                        )
                    }) {
                        Text("확인")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(searchText.count < 2 ? Color.gray.opacity(0.5) : Color.blue, lineWidth: 1)
                    )
                    .disabled(searchText.count < 2)
                }
                searchedLecturesView
            }

            // 선택된 강의들 표시
            if !selectedLectures.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedLectures.indices, id: \.self) { index in
                            let lecture = selectedLectures[index]
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
        .onChange(of: searchType) { _ in
            viewModel.resetSearchState()
        }
        .onChange(of: searchText) { _ in
            viewModel.resetSearchState()
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
    
    // 검색 기준 버튼 UI
    var searchTypeButton: some View {
        HStack(spacing: 8) {
            ForEach(["name", "professor", "code"], id: \.self) { type in
                Button(action: {
                    searchType = type
                }) {
                    Text(displayName(for: type))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(searchType == type ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(searchType == type ? .white : .black)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    // 검색 타입 문자열 → 사용자 친화적 이름
    func displayName(for type: String) -> String {
        switch type {
        case "name": return "이름"
        case "professor": return "교수"
        case "code": return "코드"
        default: return type
        }
    }
}
