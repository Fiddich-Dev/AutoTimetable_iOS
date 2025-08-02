//
//  Modifier.swift
//  AutoTimetable
//
//  Created by 황인성 on 7/9/25.
//

import SwiftUI

struct MyTextFieldModifier: ViewModifier {
    var isFocused: Bool
    
    func body(content: Content) -> some View {
        content
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


struct MyButtonModifier: ViewModifier {
    var isDisabled: Bool
    @GestureState private var isPressed = false

    func body(content: Content) -> some View {
        let pressGesture = DragGesture(minimumDistance: 0)
            .updating($isPressed) { _, state, _ in
                state = true
            }

        return content
            .foregroundStyle(Color.white)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(isDisabled ? Color.gray.opacity(0.5) : Color.blue)
            .cornerRadius(20)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
//            .gesture(pressGesture)
            .contentShape(Rectangle())
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .disabled(isDisabled)
    }
}



