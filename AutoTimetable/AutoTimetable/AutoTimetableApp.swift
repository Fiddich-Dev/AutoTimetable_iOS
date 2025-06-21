//
//  AutoTimetableApp.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/3/25.
//

import SwiftUI

@main
struct AutoTimetableApp: App {
    
    @StateObject var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isLoggedIn == true {
                ContentView()
//                    .preferredColorScheme(isDarkMode ? .dark: .light)
                    .environmentObject(authViewModel)
//                    .alert("네트워크 오류", isPresented: $authViewModel.networkErrorAlert) {
//                        Button("OK", role: .cancel) {
//                            // 강제 로그아웃
//                            self.deleteToken()
//                            self.deleteRefreshToken()
//                            authViewModel.isLoggedIn = false
//                        }
//                    }
            }
            
            else {
                LoginView()
//                    .preferredColorScheme(isDarkMode ? .dark: .light)
//                    .environmentObject(LoginNavigationPathFinder.shared)
                    .environmentObject(authViewModel)
//                    .alert("네트워크 오류", isPresented: $authViewModel.networkErrorAlert) {
//                        Button("OK", role: .cancel) {
//                        }
//                    }
            }
        }
    }
}
