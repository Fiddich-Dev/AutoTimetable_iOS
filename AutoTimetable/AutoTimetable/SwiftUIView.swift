//
//  SwiftUIView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/6/25.
//

import SwiftUI

struct SwiftUIView: View {
    
    @State var text: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField("학교 입력", text: $text)
        .focused($isFocused)
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black, lineWidth: isFocused ? 0.7 : 0.1)
        )

    }
}

#Preview {
    SwiftUIView()
}
