//
//  LectureCardView.swift
//  AutoTimetable
//
//  Created by Hwang insung on 8/2/25.
//

import SwiftUI

// 오늘 강의 카드 뷰
struct LectureCardView: View {
    
    var lectureInfo: LectureTimeInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(lectureInfo.startTime + " - " + lectureInfo.endTime)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text(lectureInfo.lecture.type)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            
            Text(lectureInfo.lecture.name)
                .font(.headline)
            
            Text(lectureInfo.lecture.professor)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !lectureInfo.lecture.notice.isEmpty {
                Text(lectureInfo.lecture.notice)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

//#Preview {
//    LectureCardView()
//}
