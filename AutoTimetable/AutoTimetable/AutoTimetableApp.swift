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
            ZStack {
                if(authViewModel.isLoading) {
                    ProgressView()
                        .zIndex(1)
                }
                
                if authViewModel.isLoggedIn == true {
                    ContentView()
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
                        .environmentObject(authViewModel)
                        .alert(authViewModel.alertMessage, isPresented: $authViewModel.showAlert) {
                            Button("확인", role: .cancel) { }
                        }
                        .alert("네트워크 오류", isPresented: $authViewModel.networkErrorAlert) {
                            Button("확인", role: .cancel) {
                            }
                        }
                }
            }
        }
    }
}
