//
//  YearAndSemesterCell.swift
//  AutoTimetable
//
//  Created by Hwang insung on 7/31/25.
//

import SwiftUI

struct YearAndSemesterCell: View {
    
    let year: String
    let semester: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text("\(year)년 \(semester)학기")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

//#Preview {
//    YearAndSemesterCell()
//}
