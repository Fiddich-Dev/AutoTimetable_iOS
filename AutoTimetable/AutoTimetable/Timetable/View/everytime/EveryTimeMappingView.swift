//
//  EveryTimeMappingView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/29/25.
//

import SwiftUI

struct EveryTimeMappingView: View {
    
    @StateObject var viewModel = GenerateTimetableViewModel()
    
    @State private var url: String = "https://everytime.kr/@1eMc2T1GfAQBsE4LK7gb"
    @FocusState private var isFocused: Bool
    
    @State var isMainTimetableSet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("에브리타임 시간표 url")
                    .font(.title)

                HStack {
                    
                    TextField("url을 입력하세요", text: $url)
                        .focused($isFocused)
                        .modifier(MyTextFieldModifier(isFocused: isFocused))
                        .padding(.bottom, 8)
                    
                    Button(action: {
                        viewModel.getAllEverytimetable(url: url)
                    }, label: {
                        Text("확인")
                    })
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(url.isEmpty ? Color.gray.opacity(0.5) : Color.blue, lineWidth: 1)
                    )
                    .disabled(url.isEmpty)
                }
                
                HStack(spacing: 0) {
                    Text("에브리타임 시간표 -> ")
                    
                    Image(systemName: "gearshape")
                    
                    Text(" -> URL 공유")
                }
                
                
                // 저장된 학년도를 루프
                ForEach(viewModel.mappedTimetables, id: \.self) { timetable in
                    
                    NavigationLink(destination: {
                        ScrollView {
                            HStack {
                                Button(action: {
                                    isMainTimetableSet.toggle()
                                }, label: {
                                    if(isMainTimetableSet) {
                                        Image(systemName: "checkmark.square")
                                    }
                                    else {
                                        Image(systemName: "square")
                                    }
                                })
                                    
                                Text("메인 시간표로 설정")
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .font(.title2)
                            
                            TimetableViewDto(lectures: timetable.lectures)
                        }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    viewModel.saveEverytimetable(year: timetable.year, semester: timetable.semester, timetableName: "기본", isRepresent: isMainTimetableSet, lectures: timetable.lectures) {
                                        
                                    }
                                }, label: {
                                    Text("저장")
                                })
                            }
                        }
                    }, label: {
                        YearAndSemesterCell(year: timetable.year, semester: timetable.semester)
                    })
                }
                
            }
            .padding(.horizontal, 20)
        }
    }
}

//struct TimetableViewDto: View {
//    
//    let days = ["월", "화", "수", "목", "금", "토", "일"]
//    let hours = Array(0..<24)
//    
//    let conerCellWidth: CGFloat = 20
//    let conerCellHeight: CGFloat = 20
//    
//    let cellHeight: CGFloat = 50
//    
//    let lectures: [ExternalLecture]
//    
//    
//    
//    
//    
//    var body: some View {
//        
//        //        ScrollView {
//        
//        VStack(spacing: 0) {
//            
//            GeometryReader { geo in
//                
//                let cellWidth = (geo.size.width - conerCellWidth) / CGFloat(self.days.count)
//                
//                // 🟦 기본 시간표 그리드
//                VStack(spacing: 0) {
//                    // 요일 헤더
//                    HStack(spacing: 0) {
//                        Text(" ")
//                            .frame(width: conerCellWidth, height: conerCellHeight)
//                        
//                        ForEach(days, id: \.self) { day in
//                            Text(day)
//                                .frame(width: cellWidth, height: conerCellHeight)
//                                .font(.caption)
//                        }
//                    }
//                    
//                    // 시간 + 셀
//                    ForEach(hours, id: \.self) { hour in
//                        HStack(spacing: 0) {
//                            Text(String(format: "%2d", hour))
//                                .frame(width: conerCellWidth, height: cellHeight, alignment: .topTrailing)
//                                .font(.caption)
//                            
//                            ForEach(0..<days.count, id: \.self) { _ in
//                                Rectangle()
//                                    .fill(Color.white)
//                                    .frame(width: cellWidth, height: cellHeight)
//                                    .border(Color.gray.opacity(0.3))
//                            }
//                        }
//                    }
//                    
//                }
//                
//                // 🟨 강의 블록
//                ForEach(lectures, id: \.self) { lecture in
//                    let blocks = createLectureBlock(lecture: lecture, cellWidth: cellWidth)
//                    
//                    
//                    ForEach(blocks.indices, id: \.self) { index in
//                        blocks[index]
//                    }
//                }
//                
//            }
//            .frame(height: CGFloat(hours.count) * cellHeight + conerCellHeight)
//        }
//        //        }
//    }
//    
//    //    "월900-1015,수1030-1145"
//    func createLectureBlock(lecture: ExternalLecture, cellWidth: CGFloat) -> [AnyView] {
//        let dayMap = ["월": 0, "화": 1, "수": 2, "목": 3, "금": 4, "토": 5, "일": 6]
//        let times = lecture.time.components(separatedBy: ",")
//        var views: [AnyView] = []
//        
//        for time in times {
//            guard let xIndex = dayMap[String(time.prefix(1))] else { continue }
//            let timeRange = time.dropFirst()
//            let parts = timeRange.split(separator: "-")
//            guard parts.count == 2,
//                  let startInt = Int(parts[0]),
//                  let endInt = Int(parts[1]) else { continue }
//            
//            let startY = (startInt / 100) * 60 + (startInt % 100)
//            let endY = (endInt / 100) * 60 + (endInt % 100)
//            
//            let height = CGFloat(endY - startY) / 60 * cellHeight
//            
//            let x = CGFloat(xIndex) * cellWidth + conerCellWidth + cellWidth / 2
//            let y = CGFloat(startY) / 60 * cellHeight + conerCellHeight + height / 2
//            
//            let block = AnyView(
//                VStack(spacing: 2) {
//                    Text(lecture.name)
//                        .font(.caption2)
//                        .lineLimit(1)
//                    Text(lecture.professor)
//                        .font(.caption2)
//                        .lineLimit(1)
//                }
//                    .frame(width: cellWidth, height: height)
//                    .background(Color.green.opacity(0.7))
//                    .cornerRadius(4)
//                    .position(x: x, y: y)
//            )
//            
//            views.append(block)
//        }
//        
//        return views
//    }
//}

//#Preview {
//    EveryTimeMappingView(viewModel: TimetableViewModel())
//}
