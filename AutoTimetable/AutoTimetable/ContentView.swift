//
//  ContentView.swift
//  AutoTimetable
//
//  Created by 황인성 on 6/3/25.
//

import SwiftUI


struct ContentView: View {
    
    @State private var selectedTab = Tab.home
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        
        
        NavigationView {
            TabView(selection: $selectedTab) {
                
                HomeView(authViewModel: authViewModel)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("홈")
                    }
                    .tag(Tab.home)
                
                TimetableTabView(authViewModel: authViewModel)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("시간표")
                    }
                    .environmentObject(authViewModel)
                    .tag(Tab.timeTable)
                
                FriendView(authViewModel: authViewModel)
                    .tabItem {
                        Image(systemName: "person.2.fill")
                        Text("친구관리")
                    }
                    .environmentObject(authViewModel)
                    .tag(Tab.friend)
                
                SettingView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("설정")
                    }
                    .tag(Tab.setting)
            }
        }
        
    }
}

enum Tab: String {
    case home = "home"
    case timeTable = "timeTable"
    case friend = "friend"
    case setting = "setting"
}


#Preview {
    ContentView()
}


