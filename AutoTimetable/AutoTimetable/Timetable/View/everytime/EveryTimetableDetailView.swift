//
//  EveryTimetableDetailView.swift
//  AutoTimetable
//
//  Created by Hwang insung on 7/31/25.
//

import SwiftUI

struct EveryTimetableDetailView: View {
    
    @ObservedObject var viewModel: GenerateTimetableViewModel
    
    @Binding var timetable: CreatedTimetable
    
    @Environment(\.dismiss) var dismiss
    @State var isMainTimetableSet = false
    @State var showAlert = false
    
    var body: some View {
        ScrollView {
            HStack {
                Button(action: {
                    isMainTimetableSet.toggle()
                    timetable.isRepresent = isMainTimetableSet
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
            
            TimetableView(lectures: timetable.lectures)
        }
        .alert("저장 되었습니다", isPresented: $showAlert) {
            Button("확인", role: .cancel) {
                dismiss()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.saveTimetable(createdTimetable: timetable, completion: {
                        showAlert = true
                    })
                }, label: {
                    Text("저장")
                })
            }
        }
    }
}

//#Preview {
//    EveryTimetableDetailView()
//}
