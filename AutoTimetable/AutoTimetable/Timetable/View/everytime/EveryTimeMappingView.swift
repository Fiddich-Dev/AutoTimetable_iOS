//
//  EveryTimeMappingView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/29/25.
//

import SwiftUI

struct EveryTimeMappingView: View {
    
    @StateObject var viewModel: GenerateTimetableViewModel
    
    @State private var url: String = ""
    @FocusState private var isFocused: Bool
    
    @State var isMainTimetableSet = false
    
    init(authViewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: GenerateTimetableViewModel(viewModel: authViewModel))
    }
    
    var body: some View {
        ZStack {
            if(viewModel.isLoading) {
                ProgressView()
            }
            
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
                    ForEach(viewModel.mappedTimetables.indices, id: \.self) { index in
                        var timetable = viewModel.mappedTimetables[index]
                        
                        NavigationLink(destination: {
                            EveryTimetableDetailView(viewModel: viewModel, timetable: $viewModel.mappedTimetables[index])
                        }, label: {
                            YearAndSemesterCell(year: timetable.year, semester: timetable.semester)
                        })
                    }
                    
                }
                .padding(.horizontal, 20)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
}




//#Preview {
//    EveryTimeMappingView(viewModel: TimetableViewModel())
//}
