//
//  ActionCardButton.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/28/25.
//

import SwiftUI

struct ActionCardButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(.primary)
                    .padding(.top, 2)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

